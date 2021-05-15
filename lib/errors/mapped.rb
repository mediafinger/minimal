# frozen_string_literal: true

module Errors
  # used by the ErrorHandler to map any non-CustomError to our custom format for logging and displaying
  class Mapped < Custom
    attr_reader :original_class

    def initialize(code:, status:, message:, original_class:, id: nil, backtrace: nil)
      @original_class = original_class
      super(message, status: status, code: code, id: id, backtrace: backtrace)
    end

    def original_class_to_code
      original_class.split("::").last.underscore
    end
  end
end
