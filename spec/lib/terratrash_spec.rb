# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/terratrash"

describe Terratrash do
  context "#initialize" do
    it "creates a Terratrash class" do
      terratrash = described_class.new
      expect(terratrash).to be_a(Terratrash)
      expect(terratrash).to respond_to(:clean)
      expect(terratrash.instance_variable_get(:@log)).to be_a(Logger)
    end
  end
end
