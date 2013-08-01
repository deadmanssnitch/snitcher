require "net/https"

module Snitcher

  # Snitches using the snitch token set in .snitches_on(token)
  def snitch!
    snitcher.checkin
  end

  class Snitch
    attr_reader :token

    def initialize(token)
      @token = token
    end

    def checkin
      http.use_ssl = true

      response = http.request(Net::HTTP::Get.new("/#{@token}"))
      response.code_type == Net::HTTPOK
    end

    def http
      @http ||= Net::HTTP.new("nosnch.in", 443)
    end

    def http=(http)
      @http=http
    end
  end

  module ClassMethods

    def by_token(token)
      Snitch.new(token)
    end

    def checkin(token)
      by_token(token).checkin
    end
    alias_method :snitch, :checkin

    def checks_in_on(token)
      @snitcher = Snitch.new(token)
    end
    alias_method :snitches_on, :checks_in_on

    def snitcher
      unless @snitcher
        raise ConfigError.new "call snitches_on in the containing class with a snitch token"
      end
      @snitcher
    end
  end

  def snitcher
    self.class.snitcher
  end

  def self.included(klazz)
    klazz.extend(ClassMethods)
  end

  class ConfigError < Exception; end
end
