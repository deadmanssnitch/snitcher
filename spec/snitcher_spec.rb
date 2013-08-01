require './lib/snitcher'
require 'ostruct'

require 'minitest/autorun'
class PoorlyConfiguredSnitcher
  include Snitcher

end

class WorkingSnitcher
  include Snitcher
  snitches_on "abc123youandme"
end


describe Snitcher do
  describe "Using Snitcher as a mixin" do
    it "requires you to set the token with checks_in_on or snitches_on" do
      snitcher = PoorlyConfiguredSnitcher.new
      proc { snitcher.snitch! }.must_raise Snitcher::ConfigError
    end

    it "Successfully snitches when snitches_on was called" do
      snitcher = WorkingSnitcher.new
      fake_http = Net::HTTP.new("example.com")
      snitcher.snitcher.http=fake_http

      fake_http.stub(:request, OpenStruct.new({ :code_type => Net::HTTPOK})) do
        assert snitcher.snitch!
      end
    end

    it "returns false when HTTP doesn't love you" do
      snitcher = WorkingSnitcher.new
      fake_http = Net::HTTP.new("example.com")
      snitcher.snitcher.http=fake_http

      fake_http.stub(:request, OpenStruct.new({ :code_type => Net::HTTPError})) do
        refute snitcher.snitch!
      end
    end
  end
end
