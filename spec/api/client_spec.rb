require "spec_helper"
require "snitcher/api/client"
require "base64"
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

  describe "#post" do
    let(:url)       { "#{scheme}#{api_key}:@#{api_url}/foo" }
    let(:data_hash) {
                      { "name" =>  "One Fish", 
                        "type" =>  {"interval": "monthly"}, 
                        "notes" => "Two Fish",
                        "tags" =>  ["red_fish", "blue_fish"]
                      }
                    }

    before do
      stub_request(:post, stub_url).to_return(:body => '{"bar": "baz"}', 
        :status => 200)
    end

    it "includes a custom user-agent" do
      client.post("foo", data_hash)

      expect(a_request(:post, url).with(headers: 
              { "User-Agent" => /\ASnitcher;.*; v#{Snitcher::VERSION}\z/ })
            ).to have_been_made
    end

    it "includes a json content type header" do
      client.post("foo", data_hash)

      expect(a_request(:post, url).with(headers: 
              { "Content-Type" => "application/json" })).to have_been_made
    end

    context "when unathorized" do
      before do
        stub_request(:post, stub_url).to_return(:status => 403)
      end

      it "returns the unauthorized hash" do
        expect(client.post("foo")).to eq(unauthorized_hash)
      end
    end

    context "when unsuccessful" do
      before do
        stub_request(:post, stub_url).to_return(:status => 404)
      end

      it "returns the failure hash" do
        expect(client.post("foo")[:message]).to include("Response unsuccessful")
      end
    end

    describe "timeout" do
      before do
        stub_request(:post, stub_url).to_raise(Timeout::Error)
      end

      it "returns the timeout hash" do
        expect(client.post("foo")).to eq(timeout_hash)
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

      expect(a_request(:get, url)).to have_been_made.once
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
                       "token": "agr0683qp4",
                       "href": "/v1/snitches/agr0683qp4",
                       "name": "Cool Test Snitch",
                       "tags": [
                         "testing",
                         "api"
                       ],
                       "status": "pending",
                       "checked_in_at": "",
                       "type": {
                         "interval": "hourly"
                       }
                     },
                     {
                       "token": "xyz8574uy2",
                       "href": "/v1/snitches/xyz8574uy2",
                       "name": "Even Cooler Test Snitch",
                       "tags": [
                         "testing"
                       ],
                       "status": "pending",
                       "checked_in_at": "",
                       "type": {
                         "interval": "hourly"
                       }
                     }
                   ]'
                }

    before do
      stub_request(:get, stub_url).to_return(:body => body, :status => 200)
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

  describe "#snitch" do
    let(:token) { "c2354d53d2" }
    let(:url)   { "#{scheme}#{api_key}:@#{api_url}/snitches/#{token}" }
    let(:body)  { '[
                     {
                       "token": "c2354d53d2",
                       "href": "/v1/snitches/c2354d53d2",
                       "name": "Cool Test Snitch",
                       "tags": [
                         "testing",
                         "api"
                       ],
                       "status": "pending",
                       "checked_in_at": "",
                       "type": {
                         "interval": "hourly"
                       }
                     }
                   ]'
                }

    before do
      stub_request(:get, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.snitch(token)

      expect(a_request(:get, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns the snitch" do
        expect(client.snitch(token)).to eq(JSON.parse(body))
      end
    end
  end

  describe "#tagged_snitches" do
    let(:tags)  { ["sneetch", "belly"] }
    let(:url)   { "#{scheme}#{api_key}:@#{api_url}/snitches?tags=sneetch,belly" }
    let(:body)  { '[
                     {
                       "token": "c2354d53d2",
                       "href": "/v1/snitches/c2354d53d2",
                       "name": "Best Kind of Sneetch on the Beach",
                       "tags": [
                         "sneetch",
                         "belly",
                         "star-belly"
                       ],
                       "status": "pending",
                       "checked_in_at": "",
                       "type": {
                         "interval": "hourly"
                       }
                     },
                     {
                       "token": "c2354d53d3",
                       "href": "/v1/snitches/c2354d53d3",
                       "name": "Have None Upon Thars",
                       "tags": [
                         "sneetch",
                         "belly",
                         "plain-belly"
                       ],
                       "status": "pending",
                       "checked_in_at": "",
                       "type": {
                         "interval": "hourly"
                       }
                     }
                   ]'
                }

    before do
      stub_request(:get, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.tagged_snitches(tags)

      expect(a_request(:get, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns the snitches" do
        expect(client.tagged_snitches(tags)).to eq(JSON.parse(body))
      end
    end
  end

  describe "#create_snitch" do
    let(:data)  { 
                  {
                    "name":     "Daily Backups",
                    "interval": "daily",
                    "notes":    "Customer and supplier tables",
                    "tags":     ["backups", "maintenance"]
                   } 
                }
    let(:url)   { "#{scheme}#{api_key}:@#{api_url}/snitches" }
    let(:body)  { '[
                     {
                       "token": "c2354d53d2",
                       "href": "/v1/snitches/c2354d53d2",
                       "name": "Daily Backups",
                       "tags": [
                         "backups",
                         "maintenance"
                       ],
                       "status": "pending",
                       "checked_in_at": "",
                       "type": {
                         "interval": "daily"
                       },
                       "notes": "Customer and supplier tables"
                     }
                   ]'
                }

    before do
      stub_request(:post, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.create_snitch(data)

      expect(a_request(:post, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns the new snitch" do
        expect(client.create_snitch(data)).to eq(JSON.parse(body))
      end
    end
  end
end