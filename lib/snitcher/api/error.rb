module Snitcher::API
  # Error is the base class for all API specific errors. For a full list of
  # errors and how they can happen please refer to the API documentation.
  #
  # https://deadmanssnitch.com/docs/api/v1#error-reference
  class Error < StandardError
    attr_reader :type

    def self.new(api_error)
      type    = api_error.delete("type")
      message = api_error.delete("error")

      klass =
        case type.to_s
          # sign_in_incorrect is only returned when using username + password.
          when "sign_in_incorrect";     AuthenticationError
          # api_key_invalid is only returned when using the API key.
          when "api_key_invalid";       AuthenticationError
          when "plan_limit_reached";    PlanLimitReachedError
          when "account_on_hold";       AccountOnHoldError
          when "resource_not_found";    ResourceNotFoundError
          when "resource_invalid";      ResourceInvalidError
          when "internal_server_error"; InternalServerError
          else                          Error
        end

      error = klass.allocate
      error.send(:initialize, type, message, api_error)
      error
    end

    def initialize(type, message = nil, metadata = nil)
      super(message)

      @type     = type
      @metadata = metadata || {}
    end
  end

  # AuthenticationError is raised from API calls when the given credentials
  # are invalid.
  class AuthenticationError < Error; end

  # PlanLimitReachedError is raised when a request fails due to that feature
  # being limited by your current plan. Most likely this is due to having too
  # many snitches.
  class PlanLimitReachedError < Error; end

  # AccountOnHoldError is raised when an account becomes delinquent due to
  # payment being rejected. This can be thrown from an API request and this can
  # be fixed by updating the credit card on file at:
  #   https://deadmanssnitch.com/account/billing
  class AccountOnHoldError < Error; end

  # ResourceNotFoundError is raised when requesting a Snitch or other resource
  # that does not exist or you do not have permission to.
  class ResourceNotFoundError < Error; end

  # ResourceInvalidError is raised when updating a resource and there are errors
  # with the update.
  class ResourceInvalidError < Error
    def errors
      @metadata.fetch("validations", []).each_with_object({}) do |tuple, memo|
        memo[tuple["attribute"]] = tuple["message"]
      end
    end
  end

  # InternalServerError is raised when something bad has happened on our end.
  # Hopefully it's nothing you did and we're already on the case getting it
  # fixed. If you're able to trigger this regularly please contact us as we
  # could use your help reproducing it.
  class InternalServerError < Error; end
end
