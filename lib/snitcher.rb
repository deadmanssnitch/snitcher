require "uri"
require "net/http"

module Snitcher
  extend self

  def snitch(token, opts = {})
    uri = URI.parse("https://nosnch.in/#{token}")

    opts = {
      :use_ssl => uri.port == 443
    }

    Net::HTTP.start(uri.host, uri.port, opts) do |http|
      if message = opts[:message]
        uri.query = URI.encode_www_form(:m => message)
      end

      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      response.is_a?(Net::HTTPSuccess)
    end
  end
end
