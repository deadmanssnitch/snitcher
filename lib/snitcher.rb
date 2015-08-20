require "uri"
require "timeout"
require "net/http"

module Snitcher
  extend self

  # Public: Check-in to Deadman's Snitch
  #
  # token - The Snitch token given by Deadman's Snitch (see the install page).
  # opts  - The hash of optional parameters that can be given during check-in:
  #         :message - Text message limited to ~250 characters.
  #         :timeout - Number of seconds to set as connect and read timeout.
  #
  # Examples
  #
  #   Snitch.snitch("c2354d53d2")
  #   # => true
  #
  # Returns true if the check-in succeeded or false if it failed
  def snitch(token, opts = {})
    uri       = URI.parse("https://nosnch.in/#{token}")
    uri.query = URI.encode_www_form(m: opts[:message]) if opts[:message]
    timeout   = opts.fetch(:timeout, 2)

    opts = {
      open_timeout: timeout,
      read_timeout: timeout,
      ssl_timeout:  timeout,
      use_ssl:      uri.port == 443
    }

    Net::HTTP.start(uri.host, uri.port, opts) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)
      request["User-Agent"] = user_agent

      response = http.request(request)
      response.is_a?(Net::HTTPSuccess)
    end
  rescue ::Timeout::Error
    false
  end

  private

  def user_agent
    # RUBY_ENGINE was not added until 1.9.3
    engine = defined?(::RUBY_ENGINE) ? ::RUBY_ENGINE : "Ruby"

    "Snitcher; #{engine}/#{RUBY_VERSION}; #{RUBY_PLATFORM}; v#{VERSION}"
  end
end

require "snitcher/version"
