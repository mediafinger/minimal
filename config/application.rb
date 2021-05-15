# frozen_string_literal: true

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
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Rack::RequestID ensures that every request has HTTP_X_REQUEST_ID set
    # It needs to reside in the callchain before ActionDispatch::RequestId
    # ActionDispatch::RequestId creates a request_id or uses HTTP_X_REQUEST_ID
    # but it will not change the request header (only sets the response header)
    config.middleware.insert_before(
      ActionDispatch::RequestId,
      ::Rack::RequestID, include_response_header: true, overwrite: false
    )

    # set rack-timeout, requests are being cut off when reaching the timeout
    config.middleware.insert_after(
      ::Rack::RequestID,
      ::Rack::Timeout, service_timeout: Settings.rack_timeout.to_i # in seconds
    )
    Rack::Timeout::Logger.disable # we only log the errors, not the verbose status messages
  end
end
