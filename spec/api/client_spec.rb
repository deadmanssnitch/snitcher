require "spec_helper"
require "snitcher/api/client"

require "securerandom"

describe Snitcher::API::Client do
  let(:api_key)   { "_caeEiZXnEyEzXXYVh2NhQ" }
  let(:options)   { { api_key: api_key } }
  let(:client)    { Snitcher::API::Client.new(options) }

  ## Use these in development for testing
  let(:api_url)   { "api.dms.dev:3000/v1" }
  let(:stub_url)  { /api\.dms\.dev/ }
  let(:scheme)    { "http://" }

  ## Use these in production
  # let(:api_url) { "api.deadmanssnitch.com/v1" }
  # let(:stub_url)  { /deadmanssnitch\.com/ }
  # let(:scheme)    { "https://" }

  let(:unauthorized_hash) { { message: "Unauthorized access" } }
  let(:timeout_hash) { { message: "Request timed out" } }

  describe "#get" do
    let(:url)       { "#{scheme}#{api_key}:@#{api_url}/foo" }

    before do
      stub_request(:get, stub_url).to_return(:body => '{"bar": "baz"}', 
        :status => 200)
    end

    it "includes a custom user-agent" do
      client.get("foo")

      expect(a_request(:get, url).with(headers: 
              { "User-Agent" => /\ASnitcher;.*; v#{Snitcher::VERSION}\z/ })
            ).to have_been_made
    end

    context "when unathorized" do
      before do
        stub_request(:get, stub_url).to_return(:status => 403)
      end

      it "returns the unauthorized hash" do
        expect(client.get("foo")).to eq(unauthorized_hash)
      end
    end

    context "when unsuccessful" do
      before do
        stub_request(:get, stub_url).to_return(:status => 404)
      end

      it "returns the failure hash" do
        expect(client.get("foo")[:message]).to include("Response unsuccessful")
      end
    end

    describe "timeout" do
      before do
        stub_request(:get, stub_url).to_raise(Timeout::Error)
      end

      it "returns the timeout hash" do
        expect(client.get("foo")).to eq(timeout_hash)
      end
    end
  end

  describe "#api_key" do
    let(:username)  { "alice@example.com" }
    let(:password)  { "password" }
    let(:options)   { { username: username, password: password } }
    let(:url)       { "#{scheme}#{username}:#{password}@#{api_url}/api_key" }

    before do
      stub_request(:get, stub_url).
        to_return(:body => "{\n  \"api_key\": \"_caeEiZXnEyEzXXYVh2NhQ\"\n}\n", 
                  :status => 200)
    end

    it "pings API with the username and password" do
      client.api_key

      expect(a_request(:get, 
        url)).to have_been_made.once
    end

    context "when successful" do
      it "returns the api_key hash" do
        api_hash = { "api_key" => "_caeEiZXnEyEzXXYVh2NhQ" }

        expect(client.api_key).to eq(api_hash)
      end
    end
  end

  describe "#snitches" do
    let(:url)   { "#{scheme}#{api_key}:@#{api_url}/snitches" }
    let(:body)  { '[
                     {
                       "token": "abd0683eb4",
                       "href": "/v1/snitches/abd0683eb4",
                       "name": "Cool Test Snitch",
                       "tags": [
                         "testing",
                         "api"
                       ],
                       "status": "pending",
                       "checked_in_at": null,
                       "type": {
                         "interval": "hourly"
                       }
                     }
                   ]'
                }

    before do
      stub_request(:get, stub_url).
        to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.snitches

      expect(a_request(:get, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns the hash of snitches" do
        expect(client.snitches).to eq(JSON.parse(body))
      end
    end
  end
end