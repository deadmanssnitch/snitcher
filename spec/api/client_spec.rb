require "spec_helper"
require "snitcher/api/client"

require "securerandom"

describe Snitcher::API::Client do
  describe ".api_key" do
    let(:username)  { "alice@example.com" }
    let(:password)  { "password" }
    let(:options)   { {username: username, password: password} }
    let(:client)    { Snitcher::API::Client.new(options)}

    ## Use these in development for testing
    let(:api_url)   { "api.dms.dev:3000/v1/api_key" }
    let(:stub_url)  { /api\.dms\.dev/ }
    let(:scheme)    { "http://" }

    ## Use these in production
    # let(:api_url) { "api.deadmanssnitch.com/v1/api_key" }
    # let(:stub_url)  { /deadmanssnitch\.com/ }
    # let(:scheme)    { "https://" }

    before do
      stub_request(:get, stub_url).
        to_return(:body => "{\n  \"api_key\": \"_caeEiZXnEyEzXXYVh2NhQ\"\n}\n", 
                  :status => 200)
    end

    it "pings API with the username and password" do
      client.api_key

      expect(a_request(:get, 
        "#{scheme}#{username}:#{password}@#{api_url}")).to have_been_made.once
    end

    it "includes a custom user-agent" do
      client.api_key

      expect(
              a_request(:get, "#{scheme}#{username}:#{password}@#{api_url}").with(
                headers: { "User-Agent" => /\ASnitcher;.*; v#{Snitcher::VERSION}\z/ })
            ).to have_been_made
    end

    context "when successful" do
      it "returns the api_key hash" do
        api_hash = {
                      "api_key" => "_caeEiZXnEyEzXXYVh2NhQ"
                   }

        expect(client.api_key).to eq(api_hash)
      end
    end

    context "when unathorized" do
      before do
        stub_request(:get, stub_url).to_return(:status => 403)
      end

      it "returns the unauthorized hash" do
        unauthorized_hash = {
                               message: "Unauthorized access"
                            }

        expect(client.api_key).to eq(unauthorized_hash)
      end
    end

    context "when unsuccessful" do
      before do
        stub_request(:get, stub_url).to_return(:status => 404)
      end

      it "returns the failure hash" do
        expect(client.api_key[:message]).to include("Response unsuccessful")
      end
    end

    describe "timeout" do
      before do
        stub_request(:get, stub_url).to_raise(Timeout::Error)
      end

      it "returns the timeout hash" do
        timeout_hash = {
                          message: "Request timed out"
                       }

        expect(client.api_key).to eq(timeout_hash)
      end
    end
  end  
end