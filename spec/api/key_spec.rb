require "spec_helper"
require "snitcher/api/key"
require "base64"
require "securerandom"

describe Snitcher::API::Key do
  let(:username)  { "alice@example.com" }
  let(:password)  { "password" }
  let(:api_endpoint)  { URI.parse("#{scheme}#{api_url}/") }
  let(:options)   { { username: username, password: password,
    api_endpoint: api_endpoint } }
  let(:agent)     { Snitcher::API::Key.new(options) }

  let(:url)       { "#{scheme}#{username}:#{password}@#{api_url}/api_key" }

  let(:api_url)   { "api.dms.dev:3000/v1" }
  let(:stub_url)  { /api\.dms\.dev/ }
  let(:scheme)    { "http://" }

  describe "#api_key" do
    before do
      stub_request(:get, stub_url).
        to_return(:body => "{\n  \"api_key\": \"_caeEiZXnEyEzXXYVh2NhQ\"\n}\n",
                  :status => 200)
    end

    it "pings API with the username and password" do
      agent.api_key

      expect(a_request(:get, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns the api_key hash" do
        api_hash = { "api_key" => "_caeEiZXnEyEzXXYVh2NhQ" }

        expect(agent.api_key).to eq(api_hash)
      end
    end
  end
end