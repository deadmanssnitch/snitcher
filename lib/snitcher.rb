require "net/https"

module Snitcher

  class Snitch
    attr_reader :token

    def initialize(token)
      @token = token
    end

    def checkin
      http = Net::HTTP.new("nosnch.in", 443)
      http.use_ssl = true

      response = http.request(Net::HTTP::Get.new("/#{@token}"))
      response.code_type == Net::HTTPOK
    end
  end

  class << self
    def by_token(token)
      Snitch.new(token)
    end

    def checkin(token)
      by_token(token).checkin
    end
    alias_method :snitch, :checkin
  end
end
