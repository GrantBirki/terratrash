# frozen_string_literal: true

require "logger"

class Terratrash
  def initialize(logger: nil, warnings: true)
    @log = logger || Logger.new($stdout, level: ENV.fetch("LOG_LEVEL", "INFO").upcase)
    @warnings = warnings # if true, remove terraform warnings
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

    # terraform warnings often are prefix with piped characters, so remove those if warnings are enabled
    # disable this if you want to see the warnings or other blocks with piped characters
    if @warnings
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

    # re-join the array into a string
    output = terraform_array.join("\n")

    # removing terraform plan -out note
    output.gsub!(/Note: You didn't use the -out option.*?actions if you run "terraform apply" now./m, "")

    # remove any leading newline(s) characters from the beginning of the string
    output.gsub!(/\A\n*/, "")
    # remove any trailing newline(s) characters from the end of the string
    output.gsub!(/\n*\z/, "")
    # if the output ends with three or more '─' characters, remove them
    output.gsub!(/─{3,}\z/, "")
    # again, remove any trailing newline(s) characters from the end of the string
    output.gsub!(/\n*\z/, "")
    # if three or more consecutive newline characters are found, replace them with one newline character
    output.gsub!(/\n{3,}/, "\n")

    return output
  end
end
