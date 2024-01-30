require "uri"
require "timeout"
require "net/http"
require "snitcher/version"

module Snitcher
  extend self

  # Check-in to Dead Man's Snitch, exceptions are raised on failures.
  #
  # @param token [String] The unique Snitch token to check-in with. This can be
  #   found on the Setup page as the last part of the HTTP check-in url. For
  #   example, c2354d53d2 is the token in http://nosnch.in/c2354d53d2.
  #
  # @param [Hash] opts
  #
  # @option opts [String] :message Text message to include with the check-in.
  #   The message is limited to 256 characters.
  #
  # @option opts [String, Fixnum, nil] :status Exit code for the check-in. A
  #   status of "", nil, or 0 are all treated as the job finishing successfully.
  #
  # @option opts [Float, Fixnum] :timeout Number of seconds to wait for a
  #   response from the server. Default is 5 seconds.
  #
  # @yield When a block is given, the block is executed. If the block raises an
  #   exception, the exception message is used as the check-in message and the stauts
  #   is set to 1. If the block succeeds, the status is set to 0.
  #
  # @example
  #   Snitch.snitch("c2354d53d2")
  #   # => true
  #
  # @example
  #   Snitch.snitch("c2354d53d2") do
  #     # do something
  #   end
  #
  # @return [Boolean] if the check-in succeeded.
  def snitch!(token, opts = {})
    # Run the block if given, and set status/message based on the result
    block_error = nil
    if block_given?
      begin
        yield
        opts[:status] ||= 0
      rescue StandardError => e
        block_error = e
        opts[:message] ||= e.inspect
        opts[:status] ||= 1
      end
    end

    params = {}
    params[:m] = opts[:message] if opts[:message]

    # It's unnecessary to send an empty status
    if opts[:status] && opts[:status] != ""
      params[:s] = opts[:status]
    end

    uri = URI.parse(checkin_url(opts, token))
    if params.any?
      uri.query = URI.encode_www_form(params)
    end

    opts = initialize_opts(opts, uri)

    result = Net::HTTP.start(uri.host, uri.port, opts) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)
      request["User-Agent"] = user_agent

      response = http.request(request)
      response.is_a?(Net::HTTPSuccess)
    end

    # Re-raise a block error if needed
    raise block_error if block_error

    result
  end

  # Check-in to Dead Man's Snitch.
  #
  # @param token [String] The unique Snitch token to check-in with. This can be
  #   found on the Setup page as the last part of the HTTP check-in url. For
  #   example, c2354d53d2 is the token in http://nosnch.in/c2354d53d2.
  #
  # @param [Hash] opts
  #
  # @option opts [String] :message Text message to include with the check-in.
  #   The message is limited to 256 characters.
  #
  # @option opts [String, Fixnum, nil] :status Exit code for the check-in. A
  #   status of "", nil, or 0 are all treated as the job finishing successfully.
  #
  # @option opts [Float, Fixnum] :timeout Number of seconds to wait for a
  #   response from the server. Default is 5 seconds.
  #
  # @yield When a block is given, the block is executed. If the block raises an
  #   exception, the exception message is used as the check-in message and the stauts
  #   is set to 1. If the block succeeds, the status is set to 0.
  # 
  # @example
  #   Snitch.snitch("c2354d53d2")
  #   # => true
  #
  # @example
  #   Snitch.snitch("c2354d53d2") do 
  #     # do something
  #   end
  #
  # @return [Boolean] if the check-in succeeded.
  def snitch(*args)
    snitch!(*args)
  rescue StandardError
    false
  end

  private

  def initialize_opts(options, uri)
    timeout = options.fetch(:timeout, 5)

    {
      open_timeout: timeout,
      read_timeout: timeout,
      ssl_timeout:  timeout,
      use_ssl:      use_ssl?(uri),
    }
  end

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
