require "spec_helper"
require "snitcher/api/client"
require "base64"
require "securerandom"

describe Snitcher::API::Client do
  subject(:client) do
    Snitcher::API::Client.new("key", endpoint: "http://api.dms.dev")
  end

  let(:stub_url)   { /api\.dms\.dev/ }
  let(:snitch_url) { "http://key:@api.dms.dev/v1/snitches" }

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

    it "returns the array of snitches" do
      expect(client.snitches).to be_a(Array)
      expect(client.snitches.first).to be_a(Snitcher::API::Snitch)
    end
  end

  describe "#snitch" do
    let(:token) { "c2354d53d2" }
    let(:url)   { "#{snitch_url}/#{token}" }
    let(:body)  { '{
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
                     "check_in_url": "https://nosnch.in/c2354d53d2",
                     "created_at": "2015-08-15T12:15:00.234Z",
                     "notes": "Save everything that is cool."
                   }'
                }

    before do
      stub_request(:get, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.snitch(token)

      expect(a_request(:get, url)).to have_been_made.once
    end

    it "returns the snitch" do
      expect(client.snitch(token)).to be_a(Snitcher::API::Snitch)
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

    it "returns the snitches" do
      expect(client.tagged_snitches(tags)).to be_a(Array)
      expect(client.tagged_snitches(tags).first).to be_a(Snitcher::API::Snitch)
    end

    it "supports spaces in tags" do
      request = stub_request(:get, "#{snitch_url}?tags=phoenix%20foundary,murggle").
        to_return(body: body, status: 200)

      client.tagged_snitches("phoenix foundary", "murggle")

      expect(request).to have_been_made.once
    end

    it "allows an array to be passed for tags" do
      request = stub_request(:get, "#{snitch_url}?tags=murggle,gurgggle").
        to_return(body: body, status: 200)

      client.tagged_snitches(["murggle", "gurgggle"])

      expect(request).to have_been_made.once
    end
  end

  describe "#create_snitch" do
    let(:data)  {
                  {
                    "name"     => "Daily Backups",
                    "interval" => "daily",
                    "notes"    => "Customer and supplier tables",
                    "tags"     => ["backups", "maintenance"]
                   }
                }
    let(:url)   { snitch_url }
    let(:body)  { '{
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
                     "check_in_url": "https://nosnch.in/c2354d53d2",
                     "created_at": "2015-08-27T18:30:23.737Z",
                     "notes": "Customer and supplier tables"
                   }'
                }

    before do
      stub_request(:post, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.create_snitch(data)

      expect(a_request(:post, url)).to have_been_made.once
    end

    it "returns the new snitch" do
      expect(client.create_snitch(data)).to be_a(Snitcher::API::Snitch)
    end

    describe "validation errors" do
      let(:data) do
        {
          "name"     => "",
          "interval" => "",
        }
      end

      let(:body) do
        '{
           "type": "resource_invalid",
           "error": "resource invalid",
           "validations": [
             { "attribute": "name", "message": "Can\'t be blank."},
             { "attribute": "type.interval", "message": "Can\'t be blank."}
           ]
         }'
      end

      it "raises ResourceInvalidError if invalid" do
        stub_request(:post, stub_url).to_return(:body => body, :status => 422)

        expect {
          client.create_snitch(data)
        }.to raise_error(Snitcher::API::ResourceInvalidError) { |error|
          expect(error.errors).to eq({
            "name"          => "Can't be blank.",
            "type.interval" => "Can't be blank.",
          })
        }
      end
    end
  end

  describe "#edit_snitch" do
    let(:token) { "c2354d53d2" }
    let(:data)  {
                  {
                    "interval" => "hourly",
                    "notes"    => "We need this more often",
                   }
                }
    let(:url)   { "#{snitch_url}/#{token}" }
    let(:body)  { '{
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
                   }'
                }

    before do
      stub_request(:patch, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.edit_snitch(token, data)

      expect(a_request(:patch, url)).to have_been_made.once
    end

    it "returns the modified snitch" do
      expect(client.edit_snitch(token, data)).to be_a(Snitcher::API::Snitch)
    end
  end

  describe "#add_tags" do
    it "adds the tags to the Snitch via the API" do
      request = stub_request(:post, "#{snitch_url}/c2354d53d2/tags").
        with(:body => %|["red","green"]|).
        to_return(:body => %|["red", "green"]|, :status => 200)

      result = client.add_tags("c2354d53d2", ["red", "green"])

      expect(request).to have_been_made.once
      expect(result).to eq(["red", "green"])
    end

    it "allows passing a single tag to add" do
      request = stub_request(:post, "#{snitch_url}/TOKEN/tags").
        with(:body => %|["extremely important"]|).
        to_return(:body => %|["extremely important"]|, :status => 200)

      result = client.add_tags("TOKEN", "extremely important")

      expect(request).to have_been_made.once
      expect(result).to eq(["extremely important"])
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
    let(:body)  { '{
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
                   }'
                }

    before do
      stub_request(:patch, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.replace_tags(token, tags)

      expect(a_request(:patch, url)).to have_been_made.once
    end

    it "returns the updated snitch" do
      expect(client.replace_tags(token, tags)).to be_a(Snitcher::API::Snitch)
    end
  end

  describe "#clear_tags" do
    let(:token) { "c2354d53d2" }
    let(:url)   { "#{snitch_url}/#{token}" }
    let(:body)  { '{
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
                   }'
                }

    before do
      stub_request(:patch, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.clear_tags(token)

      expect(a_request(:patch, url)).to have_been_made.once
    end

    it "returns the updated snitch" do
      expect(client.clear_tags(token)).to be_a(Snitcher::API::Snitch)
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
