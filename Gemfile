# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# this line is used by heroku and several CIs
ruby "3.0.1"

# only bundle the parts of Rails that are actually used
# don't forget to update config/application.rb when you add a gem
# to update the version run: `bundle update actionpack activemodel ... railties` as one command
rails_version = "6.1.3"
gem "actionpack", "~> #{rails_version}"
gem "activemodel", "~> #{rails_version}"
gem "activerecord", "~> #{rails_version}"
gem "railties", "~> #{rails_version}"

gem "pg", "~> 1.2" # postgresql db adapter
gem "puma", "~> 5.0" # web server
gem "rack-requestid", "~> 0.2" # set a request_id in the middleware
gem "rack-timeout", "~> 0.6", require: "rack/timeout/base" # set a custom timeout in the middleware
gem "sass-rails", ">= 6" # to use Sass / SCSS

group :development, :test do
  gem "amazing_print" # nicer formatted console output
  gem "bundler-audit", "~> 0.6" # to ensure no used dependencies have know security warnings
  # gem "capybara", "~> 3.33" # acceptance test framework for system tests
  gem "rspec-rails", "~> 5.0" # rspec test framework
  gem "rubocop", "~> 1.14.0", require: false # code linter
  gem "rubocop-performance", "~> 1.11" # rubocop extension
  gem "rubocop-rails", "~> 2.10" # rubocop extension
  gem "rubocop-rake", "~> 0.5" # rubocop extension
  gem "rubocop-rspec", "~> 2.0" # rubocop extension
end

group :development do
  gem "listen", "~> 3.3" # reloads changed files
end

group :test do
  # gem "selenium-webdriver", "~> 3.142" # for headless browser tests
  # gem "webmock", "~> 3.9" # stub response to requests
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
