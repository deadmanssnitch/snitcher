require "snitcher"
require "net/https"
require "json"

require "timeout"
require "snitcher/version"

module Snitcher
  module API
    extend self

    # Public: Retrieve API Key
    #
    # username: The username associated with a Deadman's Snitch account
    # password: The password associated with a Deadman's Snitch account
    #
    # options:
    #   uri: String URL of the DMS API to connect to.
    #
    # Example
    #
    #   Snitch::API.get_key("alice@example.com", "password")
    #   # => "_caeEiZXnEyEzXXYVh2NhQ"
    #
    # Returns the string api_key
    def get_key(username, password, options={})
      uri = URI.parse(api_url(options))
      http_options = initialize_opts(options, uri)

      Net::HTTP.start(uri.host, uri.port, http_options) do |http|
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = user_agent
        request.basic_auth username, password

        response = http.request(request)
        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)["api_key"]
        end
      end
    rescue Timeout::Error
      timeout_message
    end

    private

    def api_url(opts)
      if opts[:uri].nil?
        "https://api.deadmanssnitch.com/v1/api_key"
      else
        opts[:uri]
      end
    end

    def initialize_opts(options, uri)
      timeout = options.fetch(:timeout, 5)

      {
        open_timeout: timeout,
        read_timeout: timeout,
        ssl_timeout:  timeout,
        use_ssl:      use_ssl?(uri)
      }
    end

    def use_ssl?(uri)
      uri.scheme == "https"
    end

    def user_agent
      # RUBY_ENGINE was not added until 1.9.3
      engine = defined?(::RUBY_ENGINE) ? ::RUBY_ENGINE : "Ruby"

      "Snitcher; #{engine}/#{RUBY_VERSION}; #{RUBY_PLATFORM}; v#{::Snitcher::VERSION}"
    end

    def timeout_message
      { message: "Request timed out" }
    end
  end
end

require "snitcher/api/client"
