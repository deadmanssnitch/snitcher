require "spec_helper"
require "snitcher/api/client"
require "base64"
require "securerandom"

describe Snitcher::API::Client do
  let(:api_key)       { "_caeEiZXnEyEzXXYVh2NhQ" }
  let(:api_endpoint)  { "#{scheme}#{api_url}/" }
  let(:options)       { { api_key: api_key, api_endpoint: api_endpoint } }
  let(:client)        { Snitcher::API::Client.new(options) }

  let(:api_url)   { "api.dms.dev:3000/v1" }
  let(:stub_url)  { /api\.dms\.dev/ }
  let(:scheme)    { "http://" }

  let(:snitch_url)        { "#{scheme}#{api_key}:@#{api_url}/snitches" }
  let(:unauthorized_hash) { { message: "Unauthorized access" } }
  let(:timeout_hash)      { { message: "Request timed out" } }

  describe "#snitches" do
    let(:url)   { snitch_url }
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
    let(:url)   { "#{snitch_url}/#{token}" }
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
                       },
                       "check_in_url": "https://s.nosnch.in/c2354d53d2",
                       "created_at": "2015-08-15T12:15:00.234Z",
                       "notes": "Save everything that is cool."
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
    let(:url)   { "#{snitch_url}?tags=sneetch,belly" }
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
    let(:url)   { snitch_url }
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
                       "check_in_url": "https://s.nosnch.in/c2354d53d2",
                       "created_at": "2015-08-27T18:30:23.737Z",
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

  describe "#edit_snitch" do
    let(:token) { "c2354d53d2" }
    let(:data)  {
                  {
                    "interval": "hourly",
                    "notes":    "We need this more often",
                   }
                }
    let(:url)   { "#{snitch_url}/#{token}" }
    let(:body)  { '[
                     {
                       "token": "c2354d53d2",
                       "href": "/v1/snitches/c2354d53d2",
                       "name": "The Backups",
                       "tags": [
                         "backups",
                         "maintenance"
                       ],
                       "status": "pending",
                       "checked_in_at": "",
                       "type": {
                         "interval": "hourly"
                       },
                       "notes": "We need this more often"
                     }
                   ]'
                }

    before do
      stub_request(:patch, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.edit_snitch(token, data)

      expect(a_request(:patch, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns the modified snitch" do
        expect(client.edit_snitch(token, data)).to eq(JSON.parse(body))
      end
    end
  end

  describe "#add_tags" do
    let(:token) { "c2354d53d2" }
    let(:tags)  { ["red", "green"] }
    let(:url)   { "#{snitch_url}/#{token}/tags" }
    let(:body)  { '[
                     "red",
                     "green"
                   ]'
                }

    before do
      stub_request(:post, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.add_tags(token, tags)

      expect(a_request(:post, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns an array of the snitch's tags" do
        expect(client.add_tags(token, tags)).to eq(JSON.parse(body))
      end
    end
  end

  describe "#remove_tag" do
    let(:token) { "c2354d53d2" }
    let(:tag)   { "critical" }
    let(:url)   { "#{snitch_url}/#{token}/tags/#{tag}" }
    let(:body)  { '[
                     "critical"
                   ]'
                }

    before do
      stub_request(:delete, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.remove_tag(token, tag)

      expect(a_request(:delete, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns an array of the snitch's remaining tags" do
        expect(client.remove_tag(token, tag)).to eq(JSON.parse(body))
      end
    end
  end

  describe "#replace_tags" do
    let(:token) { "c2354d53d2" }
    let(:tags)  { ["red", "green"] }
    let(:url)   { "#{snitch_url}/#{token}" }
    let(:body)  { '[
                     {
                       "token": "c2354d53d2",
                       "href": "/v1/snitches/c2354d53d2",
                       "name": "Daily Backups",
                       "tags": [
                         "red",
                         "green"
                       ],
                       "status": "pending",
                       "checked_in_at": "",
                       "type": {
                         "interval": "daily"
                       },
                       "notes": "Sales data."
                     }
                   ]'
                }

    before do
      stub_request(:patch, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.replace_tags(token, tags)

      expect(a_request(:patch, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns the updated snitch" do
        expect(client.replace_tags(token, tags)).to eq(JSON.parse(body))
      end
    end
  end

  describe "#clear_tags" do
    let(:token) { "c2354d53d2" }
    let(:url)   { "#{snitch_url}/#{token}" }
    let(:body)  { '[
                     {
                       "token": "c2354d53d2",
                       "href": "/v1/snitches/c2354d53d2",
                       "name": "Daily Backups",
                       "tags": [
                       ],
                       "status": "pending",
                       "checked_in_at": "",
                       "type": {
                         "interval": "daily"
                       },
                       "notes": "Sales data."
                     }
                   ]'
                }

    before do
      stub_request(:patch, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.clear_tags(token)

      expect(a_request(:patch, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns the updated snitch" do
        expect(client.clear_tags(token)).to eq(JSON.parse(body))
      end
    end
  end

  describe "#pause_snitch" do
    let(:token) { "c2354d53d2" }
    let(:url)   { "#{snitch_url}/#{token}/pause" }
    let(:body)  { '{}' }

    before do
      stub_request(:post, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.pause_snitch(token)

      expect(a_request(:post, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns an empty response" do
        expect(client.pause_snitch(token)).to eq(JSON.parse(body))
      end
    end
  end

  describe "#delete_snitch" do
    let(:token) { "c2354d53d2" }
    let(:url)   { "#{snitch_url}/#{token}" }
    let(:body)  { '{}' }

    before do
      stub_request(:delete, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.delete_snitch(token)

      expect(a_request(:delete, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns an empty response" do
        expect(client.delete_snitch(token)).to eq(JSON.parse(body))
      end
    end
  end
end