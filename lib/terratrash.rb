# frozen_string_literal: true

require "logger"

class Terratrash
  def initialize(
    logger: nil,
    remove_warnings: true,
    remove_notes: true,
    remove_pipe_blocks: true,
    add_final_newline: true
  )
    @log = logger || Logger.new($stdout, level: ENV.fetch("LOG_LEVEL", "INFO").upcase)
    @remove_warnings = remove_warnings # if true, remove terraform warnings
    @remove_notes = remove_notes # if true, remove terraform notes
    @remove_pipe_blocks = remove_pipe_blocks # if true, remove terraform blocks with piped characters
    @add_final_newline = add_final_newline # if true, add a newline to the end of the output
  end

  # Like the clean method, but it will never raise an error
  # If an error is raised, it will return the original input
  # :param terraform: a string of the terraform output
  # :return: a string of the cleaned terraform output or the original input
  def clean!(terraform)
    return clean(terraform)
  rescue StandardError => e
    # :nocov:
    @log.error("error cleaning terraform output: #{e} - returning original input")
    @log.error("backtrace: #{e.backtrace.join("\n")}")
    return terraform
    # :nocov:
  end

  # The main method of the terratrash class
  # This method takes a string, and removes all the unwanted terraform text
  # The goal of this method is to be left with a minimal, human-readable output
  # :param terraform: a string of the terraform output
  # :return: a string of the cleaned terraform output
  def clean(terraform)
    # split the output into an array of lines
    terraform_array = terraform.split("\n")

    # remove any items from the array that include any bits of the following strings
    terraform_array = remove_terraform_loading_messages!(terraform_array)
    terraform_array = remove_github_actions_output!(terraform_array)

    # if @remove_pipe_blocks is true, remove any items from the array that include pipes
    terraform_array = remove_pipe_blocks!(terraform_array) if @remove_pipe_blocks

    # find what position in the array the line "Initializing plugins and modules..." is at
    initializing_position = terraform_array.index("Initializing plugins and modules...")

    # if the line is not found, print a warning
    unless initializing_position.nil?
      # remove all the lines from the array up to that position
      terraform_array.slice!(0..initializing_position)
      # if the very first line is now empty or a newline, remove it as well
      terraform_array.delete_at(0) if terraform_array[0].strip == ""
    end

    # re-join the array into a string (text is what we will call this string)
    text = terraform_array.join("\n")

    # terraform warnings and notes cleanup
    text = remove_warnings!(text) if @remove_warnings
    text = remove_notes!(text) if @remove_notes

    # whitespace cleanup
    text = top_and_bottom_cleanup!(text)

    return text
  end

  private

  # Helper function to remove GitHub Actions output / debug messages
  # :input input_array: an array of strings
  # :return input_array: the same array of strings, but with GitHub Actions output removed
  def remove_github_actions_output!(input_array)
    @log.debug("removing GitHub Actions output")
    input_array.delete_if { |item| item.include?("::debug::") }
    input_array.delete_if { |item| item.include?("[command]/home/runner/work/") }
    return input_array
  end

  # Helper function to remove Terraform loading messages
  # :input input_array: an array of strings
  # :return input_array: the same array of strings, but with loading messages removed
  def remove_terraform_loading_messages!(input_array)
    @log.debug("removing Terraform 'loading' messages")
    input_array.delete_if { |item| item.include?("Reading...") }
    input_array.delete_if { |item| item.include?("Refreshing state...") }
    input_array.delete_if { |item| item.include?("Read complete") }
    input_array.delete_if { |item| item.include?("Still reading...") }
    return input_array
  end

  # Helper function to remove pipe blocks
  # :input input_array: an array of strings
  # :return input_array: the same array of strings, but with pipe blocks removed
  def remove_pipe_blocks!(input_array)
    @log.debug("removing pipe blocks")
    input_array.delete_if { |item| item.include?("╷") }
    input_array.delete_if { |item| item.include?("│") }
    input_array.delete_if { |item| item.include?("╵") }
    return input_array
  end

  # Helper function to clean up the top and bottom of the 'output' before it is returned
  # :input text: a string of text
  # :return text: the same string of text, but with the top and bottom cleaned up
  def top_and_bottom_cleanup!(text)
    @log.debug("cleaning up the top and bottom of the output")
    # remove any leading newline(s) characters from the beginning of the string
    text.gsub!(/\A\n*/, "")
    # remove any trailing newline(s) characters from the end of the string
    text.gsub!(/\n*\z/, "")
    # if the text ends with three or more '─' characters, remove them
    text.gsub!(/─{3,}\z/, "")
    # again, remove any trailing newline(s) characters from the end of the string
    text.gsub!(/\n*\z/, "")
    # if three or more consecutive newline characters are found, replace them with two newline characters
    text.gsub!(/\n{3,}/, "\n\n")

    if @add_final_newline && (text[-1] != "\n")
      # if the text does not end with a newline character, add one
      text += "\n"
    end

    return text
  end

  # Helper function to remove Terraform notes
  # :input text: a string of text
  # :return text: the same string of text, but with notes removed
  def remove_notes!(text)
    @log.debug("removing Terraform 'notes'")
    # removing terraform plan -out note
    text.gsub!(/Note: You didn't use the -out option.*?actions if you run "terraform apply" now./m, "")
    return text
  end

  # Helper function to remove Terraform warnings
  # :input text: a string of text
  # :return text: the same string of text, but with warnings removed
  def remove_warnings!(text)
    @log.debug("removing Terraform 'warnings'")
    text.gsub!(/Warning:.*?similar warnings elsewhere\)/m, "")
    return text
  end
end
