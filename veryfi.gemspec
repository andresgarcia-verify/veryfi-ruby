# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "veryfi/version"

Gem::Specification.new do |spec|
  spec.name          = "veryfi"
  spec.version       = Veryfi::VERSION
  spec.authors       = ["Veryfi"]
  spec.email         = ["support@veryfi.com"]

  spec.summary       = "Veryfi SDK for Ruby"

  spec.homepage      = "https://rubygems.org/gems/veryfi"

  # Affected by git permissions issue
  # spec.files = `git ls-files -z`.split("\x0").reject do |f|
  #   f.match(%r{^(test|spec|features)/})
  # end

  spec.files = [
    ".github/workflows/release.yml",
    ".github/workflows/test.yml",
    ".gitignore",
    ".rspec",
    ".rubocop.yml",
    ".ruby-version",
    ".semaphore/semaphore.yml",
    ".yardopts",
    "Gemfile",
    "Gemfile.lock",
    "README.md",
    "Rakefile",
    "bin/autospec",
    "bin/bundle-audit",
    "bin/ci",
    "bin/console",
    "bin/quality",
    "bin/release",
    "bin/rspec",
    "bin/rubocop",
    "bin/setup",
    "coverage/coverage-badge.png",
    "docs/.gitignore",
    "docs/404.html",
    "docs/_config.yml",
    "docs/_includes/footer.html",
    "docs/_includes/header.html",
    "docs/index.markdown",
    "lib/.keep",
    "lib/veryfi.rb",
    "lib/veryfi/api/any_document.rb",
    "lib/veryfi/api/bank_statement.rb",
    "lib/veryfi/api/bank_statement_split.rb",
    "lib/veryfi/api/business_card.rb",
    "lib/veryfi/api/check.rb",
    "lib/veryfi/api/classify.rb",
    "lib/veryfi/api/document.rb",
    "lib/veryfi/api/document_tag.rb",
    "lib/veryfi/api/file_payload.rb",
    "lib/veryfi/api/line_item.rb",
    "lib/veryfi/api/pdf_split.rb",
    "lib/veryfi/api/tag.rb",
    "lib/veryfi/api/tag_operations.rb",
    "lib/veryfi/api/tax_line.rb",
    "lib/veryfi/api/w2.rb",
    "lib/veryfi/api/w2_split.rb",
    "lib/veryfi/api/w8.rb",
    "lib/veryfi/api/w9.rb",
    "lib/veryfi/client.rb",
    "lib/veryfi/configuration.rb",
    "lib/veryfi/error.rb",
    "lib/veryfi/request.rb",
    "lib/veryfi/resource.rb",
    "lib/veryfi/signature.rb",
    "lib/veryfi/version.rb",
    "veryfi.gemspec"
  ]
  
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.license = "MIT"

  spec.add_dependency "base64", "~> 0.1"
  spec.add_dependency "openssl", ">= 2.2", "< 4.1"

  # Faraday 1.10.5+ and 2.14.1+ are both fixed for CVE-2026-25765.
  # Faraday >= 2.9 requires Ruby >= 3.0, so users on Ruby 2.7 should pin
  # `~> 1.10.5` explicitly in their Gemfile.
  spec.add_dependency "faraday", ">= 1.10.5", "< 3.0"

  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "bundler-audit", "~> 0.9"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rspec-its", "~> 1.3"
  spec.add_development_dependency "rubocop", "~> 1.65"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "simplecov-badge", "~> 2.0"
  spec.add_development_dependency "vcr", "~> 6.0"
  spec.add_development_dependency "webmock", "~> 3.14"
  spec.add_development_dependency "rexml", "~> 3.4.4"
  spec.add_development_dependency "yard", "~> 0.9"
end
