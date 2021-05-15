# frozen_string_literal: true

module Errors
  class Middleware
    ERROR_DEFAULTS = { code: :internal_server_error, status: 500, message: "Sorry, something went wrong." }.freeze

    # Any exceptions that are not configured will be mapped to 500 Internal Server Error (ERROR_DEFAULTS)
    MAP_KNOWN_ERRORS = {
      "AbstractController::ActionNotFound"           => { code: :not_found, status: 404 },
      "ActionController::RoutingError"               => { code: :not_found, status: 404 },
      "ActionController::MethodNotAllowed"           => { code: :method_not_allowed, status: 405 },
      "ActionController::UnknownHttpMethod"          => { code: :method_not_allowed, status: 405 },
      "ActionController::NotImplemented"             => { code: :not_implemented, status: 501 },
      "ActionController::UnknownFormat"              => { code: :not_acceptable, status: 406 },
      "ActionController::InvalidAuthenticityToken"   => { code: :unprocessable_entity, status: 422 },
      "ActionController::InvalidCrossOriginRequest"  => { code: :unprocessable_entity, status: 422 },
      "ActionDispatch::Http::Parameters::ParseError" => { code: :bad_request, status: 400 },
      "ActionController::BadRequest"                 => { code: :bad_request, status: 400 },
      "ActionController::ParameterMissing"           => { code: :bad_request, status: 400 },
      "Rack::QueryParser::ParameterTypeError"        => { code: :bad_request, status: 400 },
      "Rack::QueryParser::InvalidParameterError"     => { code: :bad_request, status: 400 },
    }.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      request_id = env["HTTP_X_REQUEST_ID"]

      @app.call(env)
    rescue Rack::Timeout::RequestTimeoutError => e
      generic_error(e, request_id)
    rescue Errors::Custom => e
      custom_error(e, request_id)
    rescue StandardError => e # rubocop:disable Lint/DuplicateBranch
      generic_error(e, request_id)
    end

    private

    def headers
      { "Content-Type" => "application/json" } # for API errors, otherwise render error views
    end

    def generic_error(error, request_id)
      mapped_error = map_error(error, request_id)
      log_error(mapped_error)

      error_body = {
        error: {
          id: request_id || mapped_error.id,
          code: mapped_error.code,
          message: "#{error.class}: #{error.message}",
        },
      }

      [mapped_error.status, headers, [error_body.to_json]]
    end

    def custom_error(error, request_id)
      log_error(error)

      error_body = {
        error: {
          id:  error.id || request_id,
          code: error.code,
          message: "#{error.class}: #{error.message}",
        },
      }

      [error.status, headers, [error_body.to_json]]
    end

    def map_error(error, request_id = nil)
      Mapped.new(
        **ERROR_DEFAULTS.merge(
          MAP_KNOWN_ERRORS.fetch(error.class.name, {}).merge(
            message: error.try(:message) || error,
            original_class: error.class.name,
            backtrace: error.try(:backtrace),
            id: request_id
          )
        )
      )
    end

    def log_error(error)
      klass = error.respond_to?(:original_class) ? error.original_class : error.class.name

      log_entry = {
        id: error.id,
        kind: error.code,
        klass: klass,
        message: error.message.to_s.encode("UTF-8"), # to avoid Encoding::UndefinedConversionError
        status: error.status,
        stacktrace: error.backtrace,
      }

      if error.status >= 500
        logger.error(error: log_entry)
      else
        logger.warn(error: log_entry)
      end
    end

    # when rendering HTML views, instead of JSON, use a method like this and create a view template for it
    # and call it from the methods generic_error and custom_error
    #
    # def render_error_view(code:, status:, message:)
    #   rendered_message = Settings.production? ? ERROR_DEFAULTS[:message] : message # do not render details on production

    #   render "pages/error", locals: { code: code, message: rendered_message, status: status }, status: status
    # end

    def logger
      @logger ||= Rails.logger
    end
  end
end
