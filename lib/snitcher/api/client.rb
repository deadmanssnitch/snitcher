require "net/https"
require "timeout"
require "json"

require "snitcher/api"
require "snitcher/version"
require "snitcher/api/snitch"
require "snitcher/api/error"

class Snitcher::API::Client
  DEFAULT_ENDPOINT = "https://api.deadmanssnitch.com"

  # Create a new API Client for taling to Dead Man's Snitch's API.
  #
  # @param key [String] API access key (available at
  #   https://deadmanssnitch.com/account/keys).
  #
  # @param [Hash] options advanced options for customizing the client
  # @option options [String] :endpoint URL of the DMS API to connect to
  # @option options [Float, Fixnum] :timeout number of seconds to wait at most
  #   for a response from the API.
  #
  # @example Creating a new Client with an API key
  #   client = Snitcher::API::Client.new("abc123")
  #   # => #<Snitcher::API::Client...>
  #
  # @return [Snitcher::API::Client] New API Client.
  def initialize(key, options = {})
    endpoint = options[:endpoint] || DEFAULT_ENDPOINT

    @key      = key
    @endpoint = URI.parse(endpoint).freeze
    @timeout  = options.fetch(:timeout, 5.0)
  end

  # Get the list snitches on the account
  #
  # @example List the Snitches on an account
  #     client.snitches
  #     # => [ #<Snitcher::API::Snitch:...>, #<Snitcher::API::Snitch:...> ]
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  # @raise [Snitcher::API::Error] if any API errors occur.
  #
  # @return [Array<Snitcher::API::Snitch>] the snitches on the account.
  def snitches
    snitch_array(get("/v1/snitches"))
  end

  # Get a single Snitch by it's unique token.
  #
  # @param token [String] The unique token of the Snitch to get
  #
  # @example Get the Snitch with token "c2354d53d2"
  #   client.snitch("c2354d53d2")
  #
  #   # => #<Snitcher::API:: @token="c2354d53d2" ...>
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  # @raise [Snitcher::API::ResourceNotFoundError] if a Snitch does not exist
  #   with that token
  # @raise [Snitcher::API::Error] if any other API errors occur.
  #
  # @return [Snitcher::API::Snitch] the Snitch
  def snitch(token)
    payload = get("/v1/snitches/#{token}")
    Snitcher::API::Snitch.new(payload)
  end

  # Retrieve Snitches filtered by a list of tags. Only Snitches that are tagged
  # with all of the given tags will be returned.
  #
  # @param tags [String, Array<String>] the tag(s) to filter by.
  #
  # @example Get the snitches that match a list of tags
  #   client.tagged_snitches(["production","critical"])
  #
  #   # => [
  #     #<Snitcher::API::Snitch tags=["production", "critical"]>,
  #     #<Snitcher::API::Snitch tags=["production", "critical"]>,
  #   ]
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  #   with that token
  # @raise [Snitcher::API::Error] if any API errors occur.
  #
  # @return [Array<Snitcher::API::Snitch>] list of Snitches matching all tags.
  def tagged_snitches(*tags)
    (tags ||= []).flatten!

    query = URI.encode_www_form({
      # Strip extra spaces, dedupe, and clean up the list of tags to be filtered
      # by.
      tags: tags.map(&:strip).compact.uniq.join(","),
    })

    snitch_array(get("/v1/snitches?#{query}"))
  end

  # Create a new Snitch.
  #
  # @param [Hash] attributes The properties for the new Snitch
  # @option attributes [String] :name The label used for the Snitch
  # @option attributes [Hash]   :type Hash containing the interval of the Snitch.
  # @option attributes [optional, String] :notes Additional information about
  #   the Snitch. Useful to put instructions of investigating or fixing any
  #   errors.
  # @option attributes [optional, Array<String>] :tags List of labels to tag the
  #   Snitch with.
  #
  # @example Create a new Snitch
  #   client.create_snitch({
  #     name:  "Daily Backups",
  #     type:  { interval: "hourly" },
  #     notes: "On error check the print tray for paper jams",
  #     tags:  [ "backups", "maintenance" ],
  #   })
  #
  #   # => #<Snitcher::API::Snitch:...>
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  # @raise [Snitcher::API::ResourceInvalidError] if the attributes are not valid
  #   for a Snitch.
  # @raise [Snitcher::API::Error] if any other API errors occur.
  #
  # @return [Snitcher::API::Snitch] the new Snitch.
  def create_snitch(attributes={})
    payload = post("/v1/snitches", attributes)
    Snitcher::API::Snitch.new(payload)
  end

  # Update a snitch, identified by token, using passed-in values. Only changes
  # those values included in the attributes hash; other attributes are not
  # changed.
  #
  # @param token [String] The unique token of the Snitch.
  # @param [Hash] attributes the set of Snitch attributes to change.
  #
  # @option attributes [String] :name The label used for the Snitch
  # @option attributes [Hash]   :type Hash containing the interval of the Snitch.
  # @option attributes [optional, String] :notes Additional information about
  #   the Snitch. Useful to put instructions of investigating or fixing any
  #   errors.
  # @option attributes [optional, Array<String>] :tags List of labels to tag the
  #   Snitch with.
  #
  # @example Update an existing Snitch
  #     client.edit_snitch("c2354d53d2", {
  #       name: "Monthyl Backups",
  #     })
  #     # => #<Snitcher::API::Snitch:...>
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  # @raise [Snitcher::API::ResourceInvalidError] if the changes are not valid.
  # @raise [Snitcher::API::ResourceNotFoundError] if the Snitch does not exist.
  # @raise [Snitcher::API::Error] if any other API errors occur.
  #
  # Raise Timeout::Error if the API request times out
  def edit_snitch(token, attributes={})
    payload = patch("/v1/snitches/#{token}", attributes)
    Snitcher::API::Snitch.new(payload)
  end

  # Add one or more tags to an existing snitch, identified by token.
  #
  # @param token [String] The unique token of the Snitch.
  # @param tags  [Array<String>] Tag or tags to add to the list of tags already
  #   on the Snitch.
  #
  # @example Add tags to an existing snitch.
  #   client.add_tags("c2354d53d2", ["red", "green"])
  #   # => [ "yellow", "red", "green" ]
  #
  # @example Adding a single tag
  #   client.add_tags("c2354d53d2", "orange")
  #   # => [ "yellow", "orange" ]
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  # @raise [Snitcher::API::ResourceNotFoundError] if the Snitch does not exist.
  # @raise [Snitcher::API::Error] if an API errors occur.
  #
  # @return [Array<String>] full list of tags on the Snitch.
  def add_tags(token, tags=[])
    tags = [tags].flatten
    post("/v1/snitches/#{token}/tags", tags)
  end

  # Remove a tag from a Snitch.
  #
  # @param token [String] The unique token of the Snitch.
  # @param tag   [String] The tag to remove from the Snitch.
  #
  # @example Removing the "production" tag from a Snitch
  #   client.remove_tag("c2354d53d2", "production")
  #   # => [ "critical" ]
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  # @raise [Snitcher::API::ResourceNotFoundError] if the Snitch does not exist.
  # @raise [Snitcher::API::Error] if any other API errors occur.
  #
  # @return [Array<String>] list of the remaining tags on the Snitch.
  def remove_tag(token, tag)
    delete("/v1/snitches/#{token}/tags/#{tag}")
  end

  # Replace the tags on a Snitch.
  #
  # @param token [String] The unique token of the Snitch.
  # @param tags  [Array<String>] List of tags to set onto the Snitch.
  #
  # @example 
  #   client.replace_tags("c2354d53d2", ["production", "urgent"])
  #   # => #<Snitcher::API::Snitch @tags=["production", "urgent"]>
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  # @raise [Snitcher::API::ResourceNotFoundError] if the Snitch does not exist.
  # @raise [Snitcher::API::Error] if any other API errors occur.
  #
  # @return [Snitcher::API::Snitch] The updated Snitch.
  def replace_tags(token, tags=[])
    attributes = {"tags" => tags}

    edit_snitch(token, attributes)
  end

  # Remove all of a Snitch's tags.
  #
  # @param token [String] The unique token of the Snitch.
  #
  # @example Remove all tags
  #   client.clear_tags("c2354d53d2")
  #   # => #<Snitcher::API::Snitch tags=[]>
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  # @raise [Snitcher::API::ResourceNotFoundError] if the Snitch does not exist.
  # @raise [Snitcher::API::Error] if any other API errors occur.
  #
  # @return [Snitcher::API::Snitch] The updated Snitch.
  def clear_tags(token)
    edit_snitch(token, :tags => [])
  end

  # Pauses a Snitch if it can be paused. Snitches can only be paused if their
  # status is currently "failing" or "errored".
  #
  # @param token [String] The unique token of the Snitch.
  #
  # @example Pause a Snitch
  #   client.pause_snitch("c2354d53d2")
  #   # => true
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  # @raise [Snitcher::API::ResourceNotFoundError] if the Snitch does not exist.
  # @raise [Snitcher::API::Error] if any other API errors occur.
  #
  # @return [nil]
  def pause_snitch(token)
    post("/v1/snitches/#{token}/pause")

    nil
  end

  # Deletes a Snitch.
  #
  # @param token [String] The unique token of the Snitch to delete.
  #
  # @example Delete a Snitch.
  #   client.delete_snitch("c2354d53d2")
  #   # => { :message => "Response complete" }
  #
  # @raise [Timeout::Error] if the API request took too long to execute.
  # @raise [Snitcher::API::ResourceNotFoundError] if the Snitch does not exist.
  # @raise [Snitcher::API::Error] if any other API errors occur.
  #
  # @return [nil]
  def delete_snitch(token)
    delete("/v1/snitches/#{token}")

    nil
  end

  private

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
