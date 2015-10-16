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

    it "raises an error if authentication failed" do
      user = "lol@notreally.horse"
      pass = "nope"

      request = stub_request(:get, "http://#{user}:#{pass}@dms.dev/v1/api_key").
        to_return({
          :body => JSON.generate({
            :type  => "sign_in_incorrect",
            :error => "Invalid email or password."
          }),
          :status => 401
        })

      expect {
        # Some shenanigans to verify type
        begin
          Snitcher::API.get_key(user, pass, uri: "http://dms.dev")
        rescue Snitcher::API::Error => e
          expect(e.type).to eq("sign_in_incorrect")
          expect(e.message).to eq("Invalid email or password.")

          raise e
        end
      }.to raise_error(Snitcher::API::AuthenticationError)

      expect(request).to have_been_made.once
    end

    it "raises Timeout::Error on a timeout" do
      stub_request(:any, "dms.dev/v1/api_key").to_timeout

      expect {
        Snitcher::API.get_key("", "", uri: "http://dms.dev")
      }.to raise_error(Timeout::Error)
    end
  end
end
