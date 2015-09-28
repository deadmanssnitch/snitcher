require "spec_helper"
require "base64"
require "securerandom"

describe Snitcher::API do
  let(:username)  { "alice@example.com" }
  let(:password)  { "password" }
  let(:uri)       { "http://#{api_url}/api_key" }

  let(:api_url)   { "api.dms.dev:3000/v1" }
  let(:url)       { "http://#{username}:#{password}@#{api_url}/api_key" }
  let(:stub_url)  { /api\.dms\.dev/ }
  let(:key)       { "_caeEiZXnEyEzXXYVh2NhQ" }

  let(:body)      { "{\n  \"api_key\": \"_caeEiZXnEyEzXXYVh2NhQ\"\n}\n" }

  describe "#get_key" do
    before do
      stub_request(:get, stub_url).
        to_return(:body => body, :status => 200)
    end

    it "pings API with the username and password" do
      Snitcher::API.get_key(username, password, uri: uri)

      expect(a_request(:get, url)).to have_been_made.once
    end

    it "returns the api_key" do
      expect(Snitcher::API.get_key(username, password, uri: uri)).to eq(key)
    end
  end
end