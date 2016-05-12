require "snitcher"
require "net/https"
require "json"

require "timeout"
require "snitcher/version"

module Snitcher
  module API
    extend self

    # Snitcher::API::Error and subclasses
    require "snitcher/api/error"

    # Retrieve an API Key for your account.
    #
    # @param username [String] username for your Dead Man's Snitch account.
    # @param password [String] password for your Dead Man's Snitch account.
    #
    # @param [Hash] options
    # @option options [String] uri location of alternative Dead Man's Snitch API
    # @option timeout [Float, Fixnum] timeout number of seconds to wait for
    #   server response before timing out.
    #
    # @example
    #   Snitcher::API.get_key("alice@example.com", "password")
    #   # => "_caeEiZXnEyEzXXYVh2NhQ"
    #
    # @raise [Timeout::Error] if the API request took too long to execute.
    # @raise [Snitcher::API::AuthenticationError] credentials are invalid.
    # @raise [Snitcher::API::Error] if any other API errors occur.
    #
    # @return [String] the API key to use for further API requests.
    def get_key(username, password, options={})
      api = options.fetch(:uri, "https://api.deadmanssnitch.com")
      uri = URI.parse("#{api}/v1/api_key")

      timeout = options.fetch(:timeout, 5)
      http_options = {
        open_timeout: timeout,
        read_timeout: timeout,
        ssl_timeout:  timeout,
        use_ssl:      uri.scheme == "https",
      }

      Net::HTTP.start(uri.host, uri.port, http_options) do |http|
        request = Net::HTTP::Get.new(uri.path)
        request["User-Agent"] = user_agent
        request.basic_auth(username, password)

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)["api_key"]
        else
          error = JSON.parse(response.body)

          raise ::Snitcher::API::Error.new(error)
        end
      end
    end

    private

    def user_agent
      # RUBY_ENGINE was not added until 1.9.3
      engine = defined?(::RUBY_ENGINE) ? ::RUBY_ENGINE : "Ruby"

      "Snitcher; #{engine}/#{RUBY_VERSION}; #{RUBY_PLATFORM}; v#{::Snitcher::VERSION}"
    end
  end
end

require "snitcher/api/client"
