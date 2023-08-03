# terratrash 🗑️

[![test](https://github.com/GrantBirki/terratrash/actions/workflows/test.yml/badge.svg)](https://github.com/GrantBirki/terratrash/actions/workflows/test.yml) [![lint](https://github.com/GrantBirki/terratrash/actions/workflows/lint.yml/badge.svg)](https://github.com/GrantBirki/terratrash/actions/workflows/lint.yml) [![build](https://github.com/GrantBirki/terratrash/actions/workflows/build.yml/badge.svg)](https://github.com/GrantBirki/terratrash/actions/workflows/build.yml) [![release](https://github.com/GrantBirki/terratrash/actions/workflows/release.yml/badge.svg)](https://github.com/GrantBirki/terratrash/actions/workflows/release.yml) [![CodeQL](https://github.com/GrantBirki/terratrash/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/GrantBirki/terratrash/actions/workflows/codeql-analysis.yml)

A Ruby gem to discard (trash) unwanted Terraform output - for humans

## Installation 💎

You can download this Gem from either [RubyGems](https://rubygems.org/gems/terratrash) or [GitHub Packages](https://github.com/GrantBirki/terratrash/pkgs/rubygems/terratrash)

RubyGems (Recommended):

```bash
gem install terratrash
```

> RubyGems [link](https://rubygems.org/gems/terratrash)

## Usage 💻

```ruby
require "terratrash"

# Perhaps you pass in the output from a CLI argument
# remember, terraform_output is a string of text
terraform_output = ARGV[0]

# Create a new Terratrash object
terratrash = Terratrash.new

# Trash the terraform text you don't want, and be left with a concise...
# ... and human-readable output
cleaned = terratrash.clean(terraform_output)

puts cleaned
```

This Gem has a few extra options you can use:

```ruby
# The .new() method accepts a few helpful options
require "terratrash"

# Create a new Terratrash object
terratrash = Terratrash.new(
    logger: nil, # You can pass in your own logger
    remove_warnings: true, # Remove Terraform warnings (Boolean) - Default: true
    remove_notes: true, # Remove Terraform notes (Boolean) - Default: true
    remove_pipe_blocks: true, # Remove pipeblock characters (Boolean) - Default: true (|, etc.)
    add_final_newline: true # Add a final newline character (Boolean) - Default: true
)
```

> This library assumes all newlines characters are `\n` (Unix-style). If you are using Windows-style newlines (`\r\n`), you may need to convert them first.

Additionally, you can call the `.clean!()` method which will never raise an error. If an error occurs, it will return the original input.

Here are some examples of what the inputs and outputs might look like:

| Input | Output |
| --- | --- |
| [input 1](./spec/fixtures/cafe.output) | [output 1](./spec/fixtures/cafe.cleaned) |
| [input 2](./spec/fixtures/with-warnings.output) | [output 2](./spec/fixtures/with-warnings.cleaned) |

## Release 🚀

To release a new version of this gem, simply edit the [`lib/version.rb`](lib/version.rb) in this repo. When you commit your changes to `main`, a new version will be automatically released via GitHub Actions to RubyGems and GitHub Packages.
