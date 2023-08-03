# frozen_string_literal: true

require "logger"

class Terratrash
  def initialize(logger: nil, remove_warnings: true, remove_pipe_blocks: true)
    @log = logger || Logger.new($stdout, level: ENV.fetch("LOG_LEVEL", "INFO").upcase)
    @remove_warnings = remove_warnings # if true, remove terraform warnings
    @remove_pipe_blocks = remove_pipe_blocks # if true, remove terraform blocks with piped characters
  end

  def clean(terraform)
    # split the output into an array of lines
    terraform_array = terraform.split("\n")

    # remove any items from the array that include any bits of the following strings
    terraform_array.delete_if { |item| item.include?("Reading...") }
    terraform_array.delete_if { |item| item.include?("Refreshing state...") }
    terraform_array.delete_if { |item| item.include?("Read complete") }
    terraform_array.delete_if { |item| item.include?("Still reading...") }
    terraform_array.delete_if { |item| item.include?("::debug::") }
    terraform_array.delete_if { |item| item.include?("[command]/home/runner/work/") }

    # if @remove_pipe_blocks is true, remove any items from the array that include any bits of the following strings
    if @remove_pipe_blocks
      terraform_array.delete_if { |item| item.include?("╷") }
      terraform_array.delete_if { |item| item.include?("│") }
      terraform_array.delete_if { |item| item.include?("╵") }
    end

    # find what position in the array the line "Initializing plugins and modules..." is at
    initializing_position = terraform_array.index("Initializing plugins and modules...")

    # if the line is not found, print a warning
    if initializing_position.nil?
      @log.warn("could not find the line 'Initializing plugins and modules...' in the Terraform output")
    else
      # remove all the lines from the array up to that position
      terraform_array.slice!(0..initializing_position)
      # if the very first line is now empty or a newline, remove it as well
      terraform_array.delete_at(0) if terraform_array[0].strip == ""
    end

    # re-join the array into a string (text is what we will call this string)
    text = terraform_array.join("\n")

    text = remove_warnings!(text) if @remove_warnings

    # removing terraform plan -out note
    text.gsub!(/Note: You didn't use the -out option.*?actions if you run "terraform apply" now./m, "")

    # remove any leading newline(s) characters from the beginning of the string
    text.gsub!(/\A\n*/, "")
    # remove any trailing newline(s) characters from the end of the string
    text.gsub!(/\n*\z/, "")
    # if the text ends with three or more '─' characters, remove them
    text.gsub!(/─{3,}\z/, "")
    # again, remove any trailing newline(s) characters from the end of the string
    text.gsub!(/\n*\z/, "")
    # if three or more consecutive newline characters are found, replace them with one newline character
    text.gsub!(/\n{3,}/, "\n")

    return text
  end

  private

  # Helper function to remove Terraform warnings
  # :input text: a string of text
  # :return text: the same string of text, but with warnings removed
  def remove_warnings!(text)
    text.gsub!(/Warning: Experimental feature.*?similar warnings elsewhere\)/m, "")
    return text
  end
end
