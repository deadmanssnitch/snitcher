require "spec_helper"
require "base64"
require "securerandom"

describe Snitcher::API do
  describe "#get_key" do
    it "returns the api_key" do
      user = "alice@example.com"
      pass = "password"

      request = stub_request(:get, "http://#{user}:#{pass}@dms.dev/v1/api_key").
        to_return({
          :body   => '{"api_key": "_caeEiZXnEyEzXXYVh2NhQ"}',
          :status => 200
        })

      actual = Snitcher::API.get_key(user, pass, uri: "http://dms.dev")

      expect(actual).to eq("_caeEiZXnEyEzXXYVh2NhQ")
      expect(request).to have_been_made.once
    end
  end
end
