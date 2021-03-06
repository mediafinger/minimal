# frozen_string_literal: true

# From the moment you require this file "config/application.rb"
# the booting process goes like this:
#
#   1)  require "config/boot.rb" to setup load paths
#    a)  custom: require "config/settings.rb" to make all ENV variables available under the Settings class
#    b)  custom: require "config/features.rb" to make our Feature Flags available (not yet implemented)
#    --> we require our custom classes so early on, to have them available everywhere directly
#   2)  require railties and engines
#    a)  require custom gems and classes
#   3)  Define Rails.application as "class Minimal < Rails::Application"
#   4)  Run config.before_configuration callbacks
#    a)  configure generators and Middlewares
#   5)  Load config/environments/RAILS_ENV.rb
#   6)  Run config.before_initialize callbacks
#   7)  Run Railtie#initializer defined by railties, engines and application.
#       One by one, each engine sets up its load paths, routes and runs its config/initializers/* files.
#   8)  Custom Railtie#initializers added by railties, engines and applications are executed
#   9)  Build the middleware stack and run to_prepare callbacks
#   10) Run config.before_eager_load and eager_load! if eager_load is true
#   11) Run config.after_initialize callbacks

require_relative "boot"

# Make ENV variables available
require_relative "settings"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "rack/requestid"

require_relative File.expand_path("../lib/errors/middleware", __dir__)

module Minimal
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Europe/Berlin"

    # Configure additional paths from which paths Zeitwerk should load files
    # Zeitwerk autoloading, eager-loading and reloading
    config.eager_load_paths << Rails.root.join("lib").to_s

    # list all available_locales
    config.i18n.available_locales = %i(en de)
    # set the default locale
    config.i18n.default_locale = :en
    # set the current locale
    config.i18n.locale = :en

    # don't generate all those files
    config.generators do |g|
      g.helper false
      g.javascripts false
      g.stylesheets = false
      g.test_framework :rspec,
                       fixtures: false,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: false
      # g.fixture_replacement :factory_bot, dir: "spec/factories"
      # g.factory_bot suffix: "factory"
      g.system_tests = nil
    end

    # Rack::RequestID ensures that every request has HTTP_X_REQUEST_ID set
    # It needs to reside in the callchain before ActionDispatch::RequestId
    # ActionDispatch::RequestId creates a request_id or uses HTTP_X_REQUEST_ID
    # but it will not change the request header (only sets the response header)
    config.middleware.insert_before(
      ActionDispatch::RequestId,
      ::Rack::RequestID, include_response_header: true, overwrite: false
    )

    # handle all thrown exceptions with proper logging and responding with JSON (or render views if no API)
    config.middleware.insert_after(
      ActionDispatch::RequestId,
      ::Errors::Middleware
    ) unless Settings.is?(:display_rails_error_page, true)

    # set rack-timeout, requests are being cut off when reaching the timeout
    config.middleware.insert_after(
      ::Errors::Middleware, # we insert the Timeout after the Errors::Middleware to get properly formatted errors
      ::Rack::Timeout, service_timeout: Settings.rack_timeout.to_i # in seconds
    )
    Rack::Timeout::Logger.disable # we only log the errors, not the verbose status messages
  end
end
