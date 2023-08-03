# frozen_string_literal: true

require "spec_helper"
require "logger"
require_relative "../../lib/terratrash"

# a mock logger that doesn't output anything
LOGGY = Logger.new($stdout, level: "fatal")

describe Terratrash do
  context "#initialize" do
    it "creates a Terratrash class" do
      terratrash = described_class.new
      expect(terratrash).to be_a(Terratrash)
      expect(terratrash).to respond_to(:clean)
      expect(terratrash.instance_variable_get(:@log)).to be_a(Logger)
    end
  end

  context "#clean" do
    it "makes no changes to a very simple string" do
      expect(described_class.new(logger: LOGGY).clean("foo")).to eq("foo")
    end
  end
end
