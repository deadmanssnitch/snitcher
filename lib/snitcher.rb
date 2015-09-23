require "uri"
require "timeout"
require "net/http"
require "snitcher/version"

module Snitcher
  extend self

  # Public: Check-in to Deadman's Snitch
  #
  # token - The Snitch token given by Deadman's Snitch (see the install page).
  # opts  - The hash of optional parameters that can be given during check-in:
  #         :message - Text message limited to ~250 characters.
  #         :timeout - Number of seconds to set as connect and read timeout.
  #         :uri - URL to use for snitch checkins.
  #
  # Examples
  #
  #   Snitch.snitch("c2354d53d2")
  #   # => true
  #
  # Returns true if the check-in succeeded or false if it failed
  def snitch(token, opts = {})
    uri       = URI.parse(checkin_url(opts, token))
    uri.query = URI.encode_www_form(m: opts[:message]) if opts[:message]
    timeout   = opts.fetch(:timeout, 5)

    opts = {
      open_timeout: timeout,
      read_timeout: timeout,
      ssl_timeout:  timeout,
      use_ssl:      use_ssl?(uri)
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

  def checkin_url(opts, token)
    if opts[:uri].nil?
      "https://nosnch.in/#{token}"
    else
      "#{opts[:uri]}/#{token}"
    end
  end

  def use_ssl?(uri)
    uri.scheme == "https"
  end

  def user_agent
    # RUBY_ENGINE was not added until 1.9.3
    engine = defined?(::RUBY_ENGINE) ? ::RUBY_ENGINE : "Ruby"

    "Snitcher; #{engine}/#{RUBY_VERSION}; #{RUBY_PLATFORM}; v#{::Snitcher::VERSION}"
  end
end

require "snitcher/version"
