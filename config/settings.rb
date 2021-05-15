# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Instead of using ENV variables in the code,
#   read them at startup and store them in this Settings object.
# This allows to:
# - work with default values,
# - overwrite some values in a config/settings.local.rb file,
# - compare values type agnostic with the `.is?` method,
# - ensure that typos in the variable names are detected at 'compile' time
# - fail in the boot process on production systems, instead of causing RuntimeErrors
# - see all keys of externaly set values in one file
# and this all comes without the help of another dependency.

# Example:
#
# register :host, default: "localhost", mandatory: true
#
# This tries to read the ENV variables: HOST
#
# When an ENV is set, it's value will be used.
# When an ENV is not set and a `default` is given, it will use the default.
# When an ENV is not set and no default is given, it will be nil.
# When an ENV is not set and `mandatory: true` is given, it will raise `KeyError: key not found: "HOST"``
#                                                        on boot (only on production environments).
#
# Access the objects in the code from anywhere like this:
# Settings.host

class Settings
  class << self
    # sets instance variable with given name and value
    def set(var_name, value)
      instance_variable_set("@#{var_name}", value)
    end

    # creates getter method that reads the instance variable with given name
    # sets value from ENV variable or `default` value
    def register(var_name, default: nil, prefix: nil, mandatory: false)
      define_singleton_method(var_name) { instance_variable_get("@#{var_name}") }

      env_name = [prefix, var_name].compact.join("_").upcase
      # will raise a KeyError when `mandatory: true` but ENV variable not set on production?
      value = mandatory && production? ? ENV.fetch(env_name) : ENV.fetch(env_name, default)

      set(var_name, value)
    end

    # to compare a setting vs a value and 'ignore' type, no more Boolean or Number mis-comparisons
    def is?(var_name, other_value)
      public_send(var_name.to_sym).to_s == other_value.to_s
    end

    # we are treating every non-local as 'production' environment (apart from CI)
    def production?
      rails_env == "production" || rails_env == "staging"
    end

    # rubocop:disable Style/RescueStandardError
    def env_and_version
      # returns info like: "staging-770605af" if ENV APP_COMMIT_SHA is available
      return [rails_env, ENV["APP_COMMIT_SHA"]].compact.join("-") if production?

      # returns info like: "development-master-86d580d"
      [rails_env, `git branch --show-current`, `git rev-parse --short HEAD`].map(&:strip).join("-")
    rescue
      rails_env
    end
    # rubocop:enable Style/RescueStandardError
  end

  register :rails_env, default: "development", mandatory: true

  register :app_name, default: "Minimal"
  register :app_version, default: env_and_version

  # Puma server config
  register :host, default: "localhost", mandatory: true
  register :port, default: 3000, mandatory: true
  register :rails_max_threads, default: 5
  register :rails_min_threads, default: rails_max_threads
  register :pidfile, default: "tmp/pids/server.pid"
  # register :web_concurrency, default: 2, mandatory: true

  # register :rails_master_key, default: "not-so-secret-key-for-development-and-test-only", mandatory: true
  register :rails_serve_static_files, default: false

  # Database config
  # register :database_url, default: "postgresql://postgres@localhost:5432/minimal_development", mandatory: true
  register :database_host, default: "localhost", mandatory: true
  register :database_port, default: 5432, mandatory: true
  register :database_name, default: "minimal_development", mandatory: true
  register :database_username, default: "postgres", mandatory: true
  register :database_password, default: "", mandatory: true
  register :database_timout_in_milliseconds, default: 3000

  register :rack_timeout, default: 5 # seconds

  # Error pages, must never be used in production!
  register :display_rails_error_page, default: !production? && false # change to true when needed for development
  register :backtrace, default: false

  # Logs & Logging
  register :log_level, default: Settings.is?(:rails_env, :test) ? :warn : :debug
  register :log_target, default: $stdout # to write to file locally: "log/#{Settings.rails_env}.log"
  register :rails_log_to_stdout, default: true

  # Don't add secrets as 'default' values here!
  # Either set ENV vars for secrets, or add them to this file, which is in .gitignore:
  # inside use this syntax: Settings.set :password, "secret"
  load "config/settings.local.rb" if File.exist?("config/settings.local.rb")
end
