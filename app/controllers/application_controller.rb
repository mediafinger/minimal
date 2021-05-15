# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # request_id to use in logging and tracing
  def request_id
    request.headers["X-Request-Id"]
  end
end
