# frozen_string_literal: true

require_relative "lib/version"

Gem::Specification.new do |spec|
  spec.name          = "terratrash"
  spec.version       = Terratrash::Version::VERSION
  spec.authors       = ["Grant Birkinbine"]
  spec.email         = "grant.birkinbine@gmail.com"
  spec.license       = "MIT"

  spec.summary       = "A Ruby gem to discard (trash) unwanted Terraform output for humans"
  spec.description   = <<~SPEC_DESC
    A Ruby gem to discard (trash) unwanted Terraform output for humans
  SPEC_DESC

  spec.homepage = "https://github.com/grantbirki/terratrash"
  spec.metadata = {
    "source_code_uri" => "https://github.com/grantbirki/terratrash",
    "documentation_uri" => "https://github.com/grantbirki/terratrash",
    "bug_tracker_uri" => "https://github.com/grantbirki/terratrash/issues"
  }

  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]
end
