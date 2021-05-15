# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # throwing the error here, after catching it in our routes,
  # means our normal error handler process will be used
  # to log the error and display a message to the user
  def error_404
    raise ActionController::RoutingError, "Path #{request.path} could not be found"
  end

  # request_id to use in logging and tracing
  def request_id
    request.headers["X-Request-Id"]
  end
end
