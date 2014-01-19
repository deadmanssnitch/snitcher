require "net/http"

module Snitcher
  extend self

  def snitch(token)
    http = Net::HTTP.new("nosnch.in", 443)
    http.use_ssl = true

    response = http.request(Net::HTTP::Get.new("/#{token}"))
    response.is_a?(Net::HTTPSuccess)
  end
end
