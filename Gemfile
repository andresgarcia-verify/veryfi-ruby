# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in veryfi.gemspec
gemspec

# Faraday picks different lines per Ruby version (see gemspec for the
# CVE-driven rationale): the 1.10.x line is the latest Ruby-2.7-compatible
# fixed branch, the 2.x line jumps to >= 2.14.1 once Ruby >= 3.0 is
# available.
if RUBY_VERSION >= "3.0"
  gem "faraday", ">= 2.14.1", "< 3.0"
else
  gem "faraday", "~> 1.10.5"
end
