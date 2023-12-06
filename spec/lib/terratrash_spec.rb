# frozen_string_literal: true

require "spec_helper"
require "redacting_logger"
require_relative "../../lib/terratrash"

# a mock logger that doesn't output anything
LOGGY = RedactingLogger.new($stdout, level: "fatal")
FIXTURES = "spec/fixtures"

describe Terratrash do
  context "#initialize" do
    it "creates a Terratrash class" do
      terratrash = described_class.new
      expect(terratrash).to be_a(Terratrash)
      expect(terratrash).to respond_to(:clean)
      expect(terratrash.instance_variable_get(:@log)).to be_a(RedactingLogger)
    end
  end

  context "#clean" do
    it "makes no changes to a very simple string and no newline" do
      expect(described_class.new(logger: LOGGY, add_final_newline: false).clean("foo")).to eq("foo")
    end

    it "calls the bang version and does not throw an exception" do
      expect(described_class.new(logger: LOGGY, add_final_newline: false).clean!("\nfoo")).to eq("foo")
    end

    it "cleans up a terraform output that contains warnings" do
      terraform_with_warnings = File.read("#{FIXTURES}/with-warnings.output")
      terratrash = described_class.new(logger: LOGGY)
      expect(terratrash.clean(terraform_with_warnings)).to eq(File.read("#{FIXTURES}/with-warnings.cleaned"))
    end

    it "cleans up a terraform output with warnings but keeps the pipe block section and warnings" do
      terraform_with_warnings = File.read("#{FIXTURES}/with-warnings.output")
      terratrash = described_class.new(logger: LOGGY, remove_warnings: false, remove_pipe_blocks: false)
      expect(terratrash.clean(terraform_with_warnings))
        .to eq(File.read("#{FIXTURES}/with-pipe-blocks-kept.cleaned"))
    end

    it "cleans up a terraform output with the cafe example" do
      terraform_cafe_example = File.read("#{FIXTURES}/cafe.output")
      terratrash = described_class.new(logger: LOGGY)
      expect(terratrash.clean(terraform_cafe_example)).to eq(File.read("#{FIXTURES}/cafe.cleaned"))
    end

    it "cleans up a terraform output with the cafe example but it keeps 'notes'" do
      terraform_cafe_example = File.read("#{FIXTURES}/cafe.output")
      terratrash = described_class.new(logger: LOGGY, remove_notes: false)
      expect(terratrash.clean(terraform_cafe_example)).to eq(File.read("#{FIXTURES}/cafe-with-notes.cleaned"))
    end

    it "cleans up a terraform output with the grocery example but it keeps 'warnings'" do
      terraform_grocery_example = File.read("#{FIXTURES}/grocery-no-changes.output")
      terratrash = described_class.new(logger: LOGGY, remove_warnings: false)
      expect(terratrash.clean(terraform_grocery_example)).to eq(File.read("#{FIXTURES}/grocery-with-warnings.cleaned"))
    end

    it "cleans up a terraform output with the grocery example" do
      terraform_grocery_example = File.read("#{FIXTURES}/grocery-no-changes.output")
      terratrash = described_class.new(logger: LOGGY, remove_warnings: true)
      expect(terratrash.clean(terraform_grocery_example)).to eq(File.read("#{FIXTURES}/grocery.cleaned"))
    end

    it "cleans up simple terraform warning messages" do
      input = <<~HEREDOC
        Warning: This is a warning message.
        Warning: This is another warning message.
        Warning: This is a third warning message (there may be similar warnings elsewhere)
        This is the output.
      HEREDOC

      expected_output = <<~HEREDOC
        This is the output.
      HEREDOC

      terratrash = described_class.new(logger: LOGGY)
      expect(terratrash.clean(input)).to eq(expected_output)
    end

    it "cleans up leading and trailing newlines" do
      input = "\n\nThis is the output.\n\n"
      terratrash = described_class.new(logger: LOGGY)
      expect(terratrash.clean(input)).to eq("This is the output.\n")
    end

    it "cleans up leading and trailing newlines with ending dashes" do
      input = "\nThis is the output.\n\n───\n\n"
      terratrash = described_class.new(logger: LOGGY)
      expect(terratrash.clean(input)).to eq("This is the output.\n")
    end

    it "replaces consecutive newlines with a single newline" do
      input = "This is the output.\n\n\n\n"
      terratrash = described_class.new(logger: LOGGY)
      expect(terratrash.clean(input)).to eq("This is the output.\n")
    end
  end
end
