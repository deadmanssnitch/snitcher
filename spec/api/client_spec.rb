require "spec_helper"
require "snitcher/api/client"
require "base64"
require "securerandom"

describe Snitcher::API::Client do
  subject(:client) do
    Snitcher::API::Client.new("key", endpoint: "http://api.dms.dev")
  end

  let(:stub_url)   { /api\.dms\.dev/ }
  let(:snitch_url) { "http://api.dms.dev/v1/snitches" }

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
      stub_request(:get, stub_url).
        with(basic_auth: ["key", ""]).
        to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.snitches

      expect(a_request(:get, url)).to have_been_made.once
    end

    it "returns the array of snitches" do
      expect(client.snitches).to be_a(Array)
      expect(client.snitches.first).to be_a(Snitcher::API::Snitch)
    end

    it "allows filtering by a tag" do
      request = stub_request(:get, "#{snitch_url}?tags=production")
        .to_return(body: body, status: 200)

      client.snitches(tags: "production")
      expect(request).to have_been_made.once
    end

    it "allows filtering by multiple tags" do
      request = stub_request(:get, "#{snitch_url}?tags=phoenix%20foundary,murggle")
        .to_return(body: body, status: 200)

      client.snitches(tags: ["phoenix foundary", "murggle"])
      expect(request).to have_been_made.once
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

  describe "#create_snitch" do
    let(:data)  {
                  {
                    "name"  => "Daily Backups",
                    "interval" => "daily",
                    "notes" => "Customer and supplier tables",
                    "tags"  => ["backups", "maintenance"]
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

    it "takes interval as a top level key" do
      # The API as designed requires `type: { interval: "" }` with the
      # expectation that there will be more types of Snitches. This hasn't
      # happend as of 2016 and it's expected that interval will be required
      # regardless of future changes.
      #
      # Allowing interval as a top level key makes using the API easier.

      req =
        stub_request(:post, stub_url).with do |request|
          payload = JSON.parse(request.body)

          expect(payload).to have_key("type")
          expect(payload["type"]["interval"]).to eq("hourly")
        end
        .to_return(:body => body, :status => 201)

      client.create_snitch(name: "Snitch", interval: "hourly")

      expect(req).to have_been_made
    end

    it "puts precedences on type/interval over just interval" do
      # :interval is a helper but the API documentation specifies type/interval.

      req =
        stub_request(:post, stub_url).with do |request|
          payload = JSON.parse(request.body)

          expect(payload).to have_key("type")
          expect(payload["type"]["interval"]).to eq("weekly")
        end
        .to_return(:body => body, :status => 201)

      client.create_snitch({
        name: "Snitch",
        interval: "daily",
        type: { interval: "weekly" },
      })

      expect(req).to have_been_made
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

  describe "#update_snitch" do
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
      client.update_snitch(token, data)

      expect(a_request(:patch, url)).to have_been_made.once
    end

    it "returns the modified snitch" do
      expect(client.update_snitch(token, data)).to be_a(Snitcher::API::Snitch)
    end

    it "takes interval as a top level key" do
      req =
        stub_request(:patch, stub_url).with do |request|
          payload = JSON.parse(request.body)

          expect(payload).to have_key("type")
          expect(payload["type"]["interval"]).to eq("hourly")
        end
        .to_return(:body => body, :status => 200)

      client.update_snitch("c2354d53d2", interval: "hourly")

      expect(req).to have_been_made
    end

    it "puts precedences on type/interval over just interval" do
      # :interval is a helper but the API documentation specifies type/interval.

      req =
        stub_request(:patch, stub_url).with do |request|
          payload = JSON.parse(request.body)

          expect(payload).to have_key("type")
          expect(payload["type"]["interval"]).to eq("weekly")
        end
        .to_return(:body => body, :status => 200)

      client.update_snitch("c2354d53d2", {
        interval: "daily",
        type: { interval: "weekly" },
      })

      expect(req).to have_been_made
    end


    it "can tag using a single string" do
      req =
        stub_request(:patch, stub_url).with do |request|
          payload = JSON.parse(request.body)
          expect(payload["tags"]).to eq(["production"])
        end.
        and_return(body: body)

      client.update_snitch("c2354d53d2", tags: "production")
      expect(req).to have_been_made
    end

    it "can remove all tags using `nil`" do
      req =
        stub_request(:patch, stub_url).with do |request|
          payload = JSON.parse(request.body)
          expect(payload["tags"]).to eq([])
        end.
        and_return(body: body)

      client.update_snitch("c2354d53d2", tags: nil)
      expect(req).to have_been_made
    end

    it "can remove all tags using an empty hash" do
      req =
        stub_request(:patch, stub_url).with do |request|
          payload = JSON.parse(request.body)
          expect(payload["tags"]).to eq([])
        end.
        and_return(body: body)

      client.update_snitch("c2354d53d2", tags: [])
      expect(req).to have_been_made
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
    let(:body)  { '[ "critical" ]' }

    before do
      stub_request(:delete, stub_url).to_return(:body => body, :status => 200)
    end

    it "pings API with the api_key" do
      client.remove_tag(token, tag)

      expect(a_request(:delete, url)).to have_been_made.once
    end
    
    it "properly escapes tags with spaces" do
      request = stub_request(:delete, "#{snitch_url}/c2354d53d2/tags/tag%20with%20spaces").
        to_return(:body => body, :status => 200)

      client.remove_tag(token, "tag with spaces")
      expect(request).to have_been_made.once
    end

    context "when successful" do
      it "returns an array of the snitch's remaining tags" do
        expect(client.remove_tag(token, tag)).to eq(JSON.parse(body))
      end
    end
  end

  describe "#pause_snitch" do
    let(:token) { "c2354d53d2" }
    let(:url)   { "#{snitch_url}/#{token}/pause" }

    before do
      stub_request(:post, stub_url).to_return(:status => 204)
    end

    it "pings API with the api_key" do
      client.pause_snitch(token)

      expect(a_request(:post, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns an empty response" do
        expect(client.pause_snitch(token)).to eq(nil)
      end
    end
  end

  describe "#delete_snitch" do
    let(:token) { "c2354d53d2" }
    let(:url)   { "#{snitch_url}/#{token}" }

    before do
      stub_request(:delete, stub_url).to_return(:status => 204)
    end

    it "pings API with the api_key" do
      client.delete_snitch(token)

      expect(a_request(:delete, url)).to have_been_made.once
    end

    context "when successful" do
      it "returns an empty response" do
        expect(client.delete_snitch(token)).to eq(nil)
      end
    end
  end
end
