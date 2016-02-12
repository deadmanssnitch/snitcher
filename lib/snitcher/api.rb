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

    # Public: Retrieve API Key
    #
    # username: The username associated with a Deadman's Snitch account
    # password: The password associated with a Deadman's Snitch account
    #
    # options:
    #   uri     - String URL of the DMS API to connect to.
    #   timeout - Number of seconds to wait for open, read, and ssl handshake.
    #
    # Example
    #
    #   Snitcher::API.get_key("alice@example.com", "password")
    #   # => "_caeEiZXnEyEzXXYVh2NhQ"
    #
    # Returns the string api_key
    # Raises Snitcher::API::Error based on the type from the server.
    # Raises Timeout::Error if the request timed out.
    def get_key(username, password, options={})
      api = options.fetch(:uri, "https://deadmanssnitch.com")
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
