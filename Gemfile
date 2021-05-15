# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.1"

rails_version = "6.1.3"
gem "actionpack", "~> #{rails_version}"
gem "activemodel", "~> #{rails_version}"
gem "activerecord", "~> #{rails_version}"
gem "railties", "~> #{rails_version}"

gem "puma", "~> 5.0"
gem "sass-rails", ">= 6"
gem "sqlite3", "~> 1.4"

group :development, :test do
  gem "rspec-rails", "~> 5.0" # rspec test framework
  gem "rubocop", "~> 1.14.0", require: false # code linter
  gem "rubocop-performance", "~> 1.11" # rubocop extension
  gem "rubocop-rails", "~> 2.10" # rubocop extension
  gem "rubocop-rake", "~> 0.5" # rubocop extension
  gem "rubocop-rspec", "~> 2.0" # rubocop extension
end

group :development do
  gem "listen", "~> 3.3"
end

group :test do
  # tbd
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
