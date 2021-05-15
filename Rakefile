# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# Load the Rails application.
require_relative "config/application"

Rails.application.load_tasks

if %w(development test).include? Rails.env
  require "bundler/audit/task"
  require "rspec/core/rake_task"
  require "rubocop/rake_task"

  # setup task bundle:audit
  Bundler::Audit::Task.new

  # setup task rspec
  RSpec::Core::RakeTask.new(:rspec) do |t|
    # t.exclude_pattern = "**/{system}/**/*_spec.rb" # example, here how to skip integration specs
  end

  # setup taks rubocop and rubocop:auto_correct
  RuboCop::RakeTask.new

  desc "Run rubocop and the specs"
  task ci: %w(rubocop rspec bundle:audit)

  Rake::Task["default"].clear # to unset rspec as the default rake task (set by rspec-rails)
  task default: :ci
end
