module Snitcher::API
  # Error is the base class for all API specific errors.
  class Error < StandardError
    attr_reader :type

    def self.new(type, message = nil)
      klass =
        case type
        when "sign_in_incorrect";
          AuthenticationError
        else
          Error
        end

      error = klass.allocate
      error.send(:initialize, type, message)
      error
    end

    def initialize(type, message = nil)
      super(message)

      @type = type
    end
  end

  # AuthenticationError is raised from API calls when the given credentials
  # are invalid.
  class AuthenticationError < Error; end
end
