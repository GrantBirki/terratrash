# terratrash 🗑️

[![test](https://github.com/GrantBirki/terratrash/actions/workflows/test.yml/badge.svg)](https://github.com/GrantBirki/terratrash/actions/workflows/test.yml) [![lint](https://github.com/GrantBirki/terratrash/actions/workflows/lint.yml/badge.svg)](https://github.com/GrantBirki/terratrash/actions/workflows/lint.yml) [![build](https://github.com/GrantBirki/terratrash/actions/workflows/build.yml/badge.svg)](https://github.com/GrantBirki/terratrash/actions/workflows/build.yml) [![release](https://github.com/GrantBirki/terratrash/actions/workflows/release.yml/badge.svg)](https://github.com/GrantBirki/terratrash/actions/workflows/release.yml) [![CodeQL](https://github.com/GrantBirki/terratrash/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/GrantBirki/terratrash/actions/workflows/codeql-analysis.yml)

A Ruby gem to discard (trash) unwanted Terraform output - for humans

## About 💡

Terraform outputs of plans / applies are commonly placed as comments on pull requests. This is a great way to see the changes that will be made, but the output is often too verbose and difficult to read. When the changes are had to read, this can lead to improper reviews and approvals as details can be easily missed in a sea of "noise". **terratrash** aims to be a simple utility that can help "trash" the noise and leave you with a concise and human-readable Terraform output. Let's take a look at some before and after examples:

### Before

Here is a large block of messy Terraform output before it is passed through **terratrash**:

<details>
<summary>Before</summary>

```terraform
[command]/home/runner/work/_temp/123-546-789/terraform-bin plan -no-color
module.foo.data.bar.cloud: Still reading... [10s elapsed]
module.foo.data.bar.cloud: Still reading... [20s elapsed]
module.foo.data.bar.cloud: Still reading... [30s elapsed]
module.foo.data.bar.cloud: Still reading... [40s elapsed]
module.foo.data.bar.cloud: Still reading... [50s elapsed]
module.foo.data.bar.cloud: Still reading... [60s elapsed]
module.foo.data.bar.cloud: Still reading... [70s elapsed]
module.foo.data.bar.cloud: Still reading... [80s elapsed]
module.foo.data.bar.cloud: Still reading... [90s elapsed]
module.foo.data.bar.cloud: Still reading... [100s elapsed]
module.foo.data.bar.cloud: Still reading... [110s elapsed]
module.foo.data.bar.cloud: Still reading... [120s elapsed]
module.foo.data.bar.cloud: Still reading... [130s elapsed]
module.foo.data.bar.cloud: Still reading... [140s elapsed]
module.foo.data.bar.cloud: Still reading... [150s elapsed]

Blah blah blah

Initializing plugins and modules...

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
+ create

Terraform will perform the following actions:

# module.cafe.module.coffee["roasts"].beans.brew will be created
+ resource "cafe" "location" {
  + location                      = "space"
  + details                       = [
      + jsonencode(
            {
              + coffee  = {
                  + cold_brew = "yum"
                  + types            = [
                      + "dark",
                    ]
                }
              + food = {
                  + bagels        = "yes"
                  + sandwiches    = "yes"
                }
            }
        ),
    ]
  + seating                 = "tables"
  + post_codes             = [
      + "12345",
    ]
  + id                          = (known after apply)
  + hours                       = "9-5"
  + name                        = "Cafe 1"
  + internet_connection         = "YES"
  + type                        = "cafe"

  + coffee_include {
      + hot = "yes"
      + cold    = "yes"
    }
  + food_include {
      + hot = "yes"
      + cold    = "yes"
    }
}

Plan: 1 to add, 0 to change, 0 to destroy.

Warning: Experimental feature "nitro_cold_brew" is active

on modules/cafe/provider.tf line 9, in terraform:
9:   experiments = [nitro_cold_brew]

Experimental features are subject to breaking changes in future minor or
patch releases, based on feedback.

If you have feedback on the design of this feature, please open a GitHub
issue to discuss it.

(and 89 more similar warnings elsewhere)

─────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
```

</details>

### After

Here is the same block of Terraform output after it has been passed through **terratrash**:

<details>
<summary>After</summary>

```terraform
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
+ create

Terraform will perform the following actions:

# module.cafe.module.coffee["roasts"].beans.brew will be created
+ resource "cafe" "location" {
  + location                      = "space"
  + details                       = [
      + jsonencode(
            {
              + coffee  = {
                  + cold_brew = "yum"
                  + types            = [
                      + "dark",
                    ]
                }
              + food = {
                  + bagels        = "yes"
                  + sandwiches    = "yes"
                }
            }
        ),
    ]
  + seating                 = "tables"
  + post_codes             = [
      + "12345",
    ]
  + id                          = (known after apply)
  + hours                       = "9-5"
  + name                        = "Cafe 1"
  + internet_connection         = "YES"
  + type                        = "cafe"

  + coffee_include {
      + hot = "yes"
      + cold    = "yes"
    }
  + food_include {
      + hot = "yes"
      + cold    = "yes"
    }
}

Plan: 1 to add, 0 to change, 0 to destroy.
```

</details>

## Installation 💎

You can download this Gem from either [RubyGems](https://rubygems.org/gems/terratrash) or [GitHub Packages](https://github.com/GrantBirki/terratrash/pkgs/rubygems/terratrash)

RubyGems (Recommended):

```bash
gem install terratrash
```

> RubyGems [link](https://rubygems.org/gems/terratrash)

## Usage 💻

This Gem is pretty flexible and doesn't really enforce any particular method usage. You could read a string of Terraform output text in with `ARGV[0]` (via the CLI), have your Ruby script read in a file, or even have your Ruby script call `terraform plan` and read in the output from that command. It doesn't really matter how you get the Terraform output text, as long as you have it in a string and pass that string into `.clean()`, this Gem will try its best to clean it up for you!

Here is an example that shows how you might use this Gem by passing in a string of Terraform output text via a CLI argument to a Ruby script:

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
