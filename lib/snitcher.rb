require "uri"
require "timeout"
require "net/http"

module Snitcher
  extend self

  def snitch(token, opts = {})
    uri     = URI.parse("https://nosnch.in/#{token}")
    timeout = opts.fetch(:timeout, 2)

    opts = {
      :open_timeout => timeout,
      :read_timeout => timeout,
      :ssl_timeout  => timeout,
      :use_ssl      => uri.port == 443
    }

    Net::HTTP.start(uri.host, uri.port, opts) do |http|
      if message = opts[:message]
        uri.query = URI.encode_www_form(:m => message)
      end

      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      response.is_a?(Net::HTTPSuccess)
    end
  rescue ::Timeout::Error
    false
  end
end
