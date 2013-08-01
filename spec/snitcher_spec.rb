require './lib/snitcher'
require 'ostruct'

require 'minitest/autorun'
class PoorlyConfiguredSnitcher
  include Snitcher::Snitchable

end

class WorkingSnitcher
  include Snitcher::Snitchable
  snitches_on "abc123youandme"
end


describe Snitcher::Snitchable do
  describe "When a snitch token was not set" do
    it "requires you to set the token with checks_in_on or snitches_on" do
      snitcher = PoorlyConfiguredSnitcher.new
      proc { snitcher.snitch! }.must_raise Snitcher::ConfigError
    end
  end

  describe "When a snitch token is set" do
    let(:snitcher) { WorkingSnitcher.new }
    let(:fake_http) { Net::HTTP.new("example.com") }
    before { snitcher.snitcher.http=fake_http }
    it "Successfully snitches when snitches_on was called" do
      fake_http.stub(:request, OpenStruct.new({ :code_type => Net::HTTPOK})) do
        assert snitcher.snitch!
      end
    end

    it "returns false when HTTP doesn't love you" do
      fake_http.stub(:request, OpenStruct.new({ :code_type => Net::HTTPError})) do
        refute snitcher.snitch!
      end
    end
  end
end
