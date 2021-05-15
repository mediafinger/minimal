# frozen_string_literal: true

# 'staging' should be configured like the production environment

# Based on production defaults
require Rails.root.join("config/environments/production")

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
end
