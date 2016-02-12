require "pp"

require "net/https"
require "timeout"
require "json"

require "snitcher/api"
require "snitcher/version"
require "snitcher/api/snitch"
require "snitcher/api/error"

class Snitcher::API::Client
  DEFAULT_ENDPOINT = "https://api.deadmanssnitch.com"

  # Public: Create a new Client
  #
  # key - Access key available at https://deadmanssnitch.com/account/keys.
  #
  # options
  #   endpoint - String URL of the DMS API connecting to.
  #   timeout  - Number of seconds to wait at most when making a request.
  #
  # Example
  #
  #   Initialize API client for user with api key "abc123"
  #     @client = Snitcher::API::Client.new("abc123")
  #
  def initialize(key, options = {})
    endpoint = options[:endpoint] || DEFAULT_ENDPOINT

    @key      = key
    @endpoint = URI.parse(endpoint).freeze
    @timeout  = options.fetch(:timeout, 5.0)
  end

  # Public: List snitches on the account
  #
  # Example
  #
  #   Get a list of all snitches
  #     @client.snitches
  #     => [#<Snitcher::API::Snitch:0x007fdcf51ec380 @token="c2354d53d3",
  #          @name="Daily Backups", @tags=["production", "critical"],
  #          @status="healthy", @checked_in_at="2014-01-01T12:00:00.000Z",
  #          @interval="daily", @check_in_url="https://nosnch.in/c2354d53d3",
  #          @created_at="2014-01-01T08:00:00.000Z", @notes=nil>,
  #         #<Snitcher::API::Snitch:0x007fdcf51ec358 @token="c2354d53d4",
  #          @name="Hourly Emails", @tags=[], @status="healthy",
  #          @checked_in_at="2014-01-01T12:00:00.000Z", @interval="hourly",
  #          @check_in_url="https://nosnch.in/c2354d53d4",
  #          @created_at="2014-01-01T07:50:00.000Z", @notes=nil>]
  #
  # Raise Timeout::Error if the API request times out
  def snitches
    snitch_array(get("/v1/snitches"))
  end

  # Public: Get a single snitch by unique token
  #
  # token: The unique token of the snitch to get. Should be a string.
  #
  # Example
  #
  #   Get the snitch with token "c2354d53d2"
  #
  #     @client.snitch("c2354d53d2")
  #     => #<Snitcher::API::Snitch:0x007fdcf50ad2d0 @token="c2354d53d3",
  #         @name="Daily Backups", @tags=["production", "critical"],
  #         @status="pending", @checked_in_at=nil, @interval="daily",
  #         @check_in_url="https://nosnch.in/c2354d53d3",
  #         @created_at="2015-08-15T12:15:00.234Z",
  #         @notes="Important user data.">
  #
  # Raise Timeout::Error if the API request times out
  def snitch(token)
    payload = get("/v1/snitches/#{token}")
    Snitcher::API::Snitch.new(payload)
  end

  # Public: Retrieve snitches that match all of the tags in a list
  #
  # tags: An array of strings. Each string is a tag.
  #
  # Example
  #
  #   Get the snitches that match a list of tags
  #     @client.tagged_snitches(["production","critical"])
  #     => [#<Snitcher::API::Snitch:0x007fdcf51ec380 @token="c2354d53d3",
  #          @name="Daily Backups", @tags=["production", "critical"],
  #          @status="pending", @checked_in_at=nil, @interval="daily",
  #          @check_in_url="https://nosnch.in/c2354d53d3",
  #          @created_at="2014-01-01T08:00:00.000Z", @notes=nil>,
  #         #<Snitcher::API::Snitch:0x007fdcf51ec358 @token="c2354d53d4",
  #          @name="Hourly Emails", @tags=["production", "critical"],
  #          @status="healthy", @checked_in_at="2014-01-01T12:00:00.000Z",
  #          @interval="hourly", @check_in_url="https://nosnch.in/c2354d53d4",
  #          @created_at="2014-01-01T07:50:00.000Z", @notes=nil>]
  #
  # Raise Timeout::Error if the API request times out
  def tagged_snitches(*tags)
    (tags ||= []).flatten!

    query = URI.encode_www_form({
      # Strip extra spaces, dedupe, and clean up the list of tags to be filtered
      # by.
      tags: tags.map(&:strip).compact.uniq.join(","),
    })

    snitch_array(get("/v1/snitches?#{query}"))
  end

  # Public: Create a snitch using passed-in values. Returns the new snitch.
  #
  # attributes: A hash of the snitch properties. It should include these keys:
  #               "name":     String value is the name of the snitch
  #               "interval": String value representing how often the snitch is
  #                           expected to fire. Options are "hourly", "daily",
  #                           "weekly", "monthly"
  #               "notes":    Optional string value for recording additional
  #                           information about the snitch
  #               "tags":     Optional array of string tags
  #
  # Example
  #
  #   Create a new snitch
  #     attributes = {
  #       "name": "Daily Backups",
  #       "interval": "daily",
  #       "notes": "Customer and supplier tables",
  #       "tags": ["backups", "maintenance"]
  #     }
  #     @client.create_snitch(attributes)
  #     => #<Snitcher::API::Snitch:0x007fdcf50ad2d0 @token="c2354d53d3",
  #         @name="Daily Backups", @tags=["backups", "maintenance"],
  #         @status="pending", @checked_in_at=nil, @interval="daily",
  #         @check_in_url="https://nosnch.in/c2354d53d3",
  #         @created_at="2015-08-15T12:15:00.234Z",
  #         @notes="Customer and supplier tables">
  #
  # Raise Timeout::Error if the API request times out
  def create_snitch(attributes={})
    payload = post("/v1/snitches", attributes)
    Snitcher::API::Snitch.new(payload)
  end

  # Public: Edit an existing snitch, identified by token, using passed-in
  #         values. Only changes those values included in the attributes
  #         hash; other attributes are not changed. Returns the updated snitch.
  #
  # token:      The unique token of the snitch to get. Should be a string.
  # attributes: A hash of the snitch properties. It should only include those
  #             values you want to change. Options include these keys:
  #               "name":     String value is the name of the snitch
  #               "interval": String value representing how often the snitch
  #                           is expected to fire. Options are "hourly",
  #                           "daily", "weekly", and "monthly".
  #               "notes":    Optional string value for recording additional
  #                           information about the snitch
  #               "tags":     Optional array of string tags
  #
  # Example
  #
  #   Edit an existing snitch using values passed in a hash.
  #     token      = "c2354d53d2"
  #     attributes = {
  #       "name":     "Monthly Backups",
  #       "interval": "monthly"
  #     }
  #     @client.edit_snitch(token, attributes)
  #     => #<Snitcher::API::Snitch:0x007fdcf50ad2d0 @token="c2354d53d3",
  #         @name="Monthly Backups", @tags=["backups", "maintenance"],
  #         @status="pending", @checked_in_at=nil, @interval="monthly",
  #         @check_in_url="https://nosnch.in/c2354d53d3",
  #         @created_at="2015-08-15T12:15:00.234Z",
  #         @notes="Customer and supplier tables">
  #
  # Raise Timeout::Error if the API request times out
  def edit_snitch(token, attributes={})
    payload = patch("/v1/snitches/#{token}", attributes)
    Snitcher::API::Snitch.new(payload)
  end

  # Public: Add one or more tags to an existing snitch, identified by token.
  #         Returns an array of the snitch's tags.
  #
  # token:  The unique token of the snitch to edit. Should be a string.
  # tags:   Array of string tags. Will append these tags to any existing tags.
  #
  # Example
  #
  #   Add tags to an existing snitch.
  #     token = "c2354d53d2"
  #     tags =  [ "red", "green" ]
  #     @client.add_tags(token, tags)
  #     => [
  #           "red",
  #           "green"
  #        ]
  #
  # Raise Timeout::Error if the API request times out
  def add_tags(token, tags=[])
    post("/v1/snitches/#{token}/tags", tags)
  end

  # Public: Remove a tag from an existing snitch, identified by token.
  #         Returns an array of the snitch's tags.
  #
  # token:  The unique token of the snitch to edit. Should be a string.
  # tag:    Tag to be removed from a snitch's tags. Should be a string.
  #
  # Example
  #
  #   Assume a snitch that already has the tags "critical" and "production"
  #     token = "c2354d53d2"
  #     tag =   "production"
  #     @client.remove_tag(token, tag)
  #     => [
  #           "critical"
  #        ]
  #
  # Raise Timeout::Error if the API request times out
  def remove_tag(token, tag)
    delete("/v1/snitches/#{token}/tags/#{tag}")
  end

  # Public: Replace all of a snitch's tags with those supplied.
  #         Returns the updated snitch.
  #
  # token:  The unique token of the snitch to edit. Should be a string.
  # tags:   Array of string tags. Will replace the snitch's current tags with
  #         these.
  #
  # Example
  #
  #   Assume a snitch with the tag "critical". Replace with tags provided.
  #     token = "c2354d53d3"
  #     tags =  ["production", "urgent"]
  #     @client.replace_tags(token, tags)
  #     => #<Snitcher::API::Snitch:0x007fdcf50ad2d0 @token="c2354d53d3",
  #         @name="Daily Backups", @tags=["production", "urgent"],
  #         @status="pending", @checked_in_at=nil, @interval="daily",
  #         @check_in_url="https://nosnch.in/c2354d53d3",
  #         @created_at="2015-08-15T12:15:00.234Z",
  #         @notes="Customer and supplier tables">
  #
  # Raise Timeout::Error if the API request times out
  def replace_tags(token, tags=[])
    attributes = {"tags" => tags}

    edit_snitch(token, attributes)
  end

  # Public: Remove all of a snitch's tags.
  #         Returns the updated snitch.
  #
  # token: The unique token of the snitch to edit. Should be a string.
  #
  # Example
  #
  #   Remove all tags.
  #     token = "c2354d53d3"
  #     @client.clear_tags(token)
  #     => #<Snitcher::API::Snitch:0x007fdcf50ad2d0 @token="c2354d53d3",
  #         @name="Daily Backups", @tags=[], @status="pending",
  #         @checked_in_at=nil, @interval="daily",
  #         @check_in_url="https://nosnch.in/c2354d53d3",
  #         @created_at="2015-08-15T12:15:00.234Z",
  #         @notes="Customer and supplier tables">
  #
  # Raise Timeout::Error if the API request times out
  def clear_tags(token)
    edit_snitch(token, :tags => [])
  end

  # Public: Pauses a snitch. The return is a hash with the message "Response
  #         complete".
  #
  # token: The unique token of the snitch to pause. Should be a string.
  #
  # Example
  #
  #   Pause a snitch.
  #     token = "c2354d53d3"
  #     @client.pause_snitch(token)
  #     => { :message => "Response complete" }
  #
  # Raise Timeout::Error if the API request times out
  def pause_snitch(token)
    post("/v1/snitches/#{token}/pause")
  end

  # Public: Deletes a snitch. The return is a hash with the message "Response
  #         complete".
  #
  # token: The unique token of the snitch to delete. Should be a string.
  #
  # Example
  #
  #   Delete a snitch.
  #     token = "c2354d53d3"
  #     @client.delete_snitch(token)
  #     => { :message => "Response complete" }
  #
  # Raise Timeout::Error if the API request times out
  def delete_snitch(token)
    delete("/v1/snitches/#{token}")
  end

  protected

  def user_agent
    # RUBY_ENGINE was not added until 1.9.3
    engine = defined?(::RUBY_ENGINE) ? ::RUBY_ENGINE : "Ruby"

    "Snitcher; #{engine}/#{RUBY_VERSION}; #{RUBY_PLATFORM}; v#{::Snitcher::VERSION}"
  end

  def execute_request(request, options={})
    http_options = {
      open_timeout: @timeout,
      read_timeout: @timeout,
      ssl_timeout:  @timeout,
      use_ssl:      @endpoint.scheme == "https",
    }

    Net::HTTP.start(@endpoint.host, @endpoint.port, http_options) do |http|
      request.basic_auth(@key, "")
      request["User-Agent"] = user_agent

      # All requests (with bodies) are made using JSON.
      if request.body
        request["Content-Type"] = "application/json"

        # Some trickiery to allow pushing the JSON rendering down as far as
        # possible.
        if !request.body.is_a?(String)
          request.body = JSON.generate(request.body)
        end
      end

      response = http.request(request)
      evaluate_response(response)
    end
  end

  def evaluate_response(response)
    case response
    when Net::HTTPNoContent
      nil
    when Net::HTTPSuccess
      JSON.parse(response.body)
    when Net::HTTPInternalServerError
      # InternalServerError does not have a parseable body as the error may not
      # be generated by the application itself.
      raise ::Snitcher::API::InternalServerError.new(
        "http_#{response.code}", response.body
      )
    else
      error = JSON.parse(response.body)

      raise ::Snitcher::API::Error.new(error)
    end
  end

  def get(path, options={})
    request = Net::HTTP::Get.new(path)
    execute_request(request, options)
  end

  def post(path, data=nil, options={})
    request = Net::HTTP::Post.new(path)
    request.body = data

    execute_request(request, options)
  end

  def patch(path, data, options={})
    request = Net::HTTP::Patch.new(path)
    request.body = data

    execute_request(request, options)
  end

  def delete(path, options={})
    request = Net::HTTP::Delete.new(path)
    execute_request(request, options)
  end

  private

  def snitch_array(json_payload)
    arr = []
    json_payload.each do |payload|
      arr << Snitcher::API::Snitch.new(payload)
    end
    arr
  end
end
