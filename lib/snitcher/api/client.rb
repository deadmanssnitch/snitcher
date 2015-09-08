require "pp"

require "net/https"
require "timeout"
require "base64"
require "json"

require "snitcher/api"
require "snitcher/version"

class Snitcher::API::Client
  # Public: Create a new Client
  #
  # options:
  #   api_key: access key available at https://deadmanssnitch.com/users/edit
  #   username: the username associated with a Snitcher account
  #   password: the password associated with a Snitcher account
  #
  # Example
  #
  #   Get the api_key for user alice@example.com
  #     @client = Snitcher::API::Client.new({api_key: "abc123"})
  #     => #<Snitcher::API::Client:0x007fa3750af418 @api_key=abc123
  #          @username=nil, @password=nil, @api_endpoint=#<URI::HTTPS
  #          https://api.deadmanssnitch.com/v1/>>
  #
  def initialize(options = {})
    @api_key      = options[:api_key]
    @username     = options[:username]
    @password     = options[:password]

    ## Use in production
    @api_endpoint = URI.parse("https://api.deadmanssnitch.com/v1/")
    ## Use in development for testing
    # @api_endpoint = URI.parse("http://api.dms.dev:3000/v1/")

    # @api_endpoint = URI.parse("http://staging-api.deadmanssnitch.com/v1/")
  end

  # Public: Retrieve API key based on username and password
  #
  # username - The username associated with a Deadman's Snitch account
  # password - The password associated with a Deadman's Snitch account
  #
  # Examples
  #
  #   Get the api_key for user alice@example.com
  #     @client = Snitcher::API::Client.new({username: "alice@example.com",
  #                 password: "password"})
  #     @client.api_key
  #     => {
  #          "api_key" => "_caeEiZXnEyEzXXYVh2NhQ"
  #        }
  #
  # When the request is unsuccessful, the endpoint returns a hash
  # with a message indicating the nature of the failure.
  def api_key
    get "/api_key"
  end

  # Public: List snitches on the account
  #
  # Examples
  #
  #   Get a list of all snitches
  #     @client.snitches
  #     => [
  #          {
  #            "token": "c2354d53d3",
  #            "href": "/v1/snitches/c2354d53d3",
  #            "name": "Daily Backups",
  #            "tags": [
  #              "production",
  #              "critical"
  #            ],
  #            "status": "healthy",
  #            "checked_in_at": "2014-01-01T12:00:00.000Z",
  #            "type": {
  #              "interval": "daily"
  #            }
  #          },
  #          {
  #            "token": "c2354d53d4",
  #            "href": "/v1/snitches/c2354d53d4",
  #            "name": "Hourly Emails",
  #            "tags": [
  #            ],
  #            "status": "healthy",
  #            "checked_in_at": "2014-01-01T12:00:00.000Z",
  #            "type": {
  #              "interval": "hourly"
  #            }
  #          }
  #        ]
  def snitches
    get "/snitches"
  end

  # Public: Get a single snitch by unique token
  #
  # token - The unique token of the snitch to get. Should be a string.
  #
  # Examples
  #
  #   Get the snitch with token "c2354d53d2"
  #     @client.snitch("c2354d53d2")
  #     => [
  #          {
  #            "token": "c2354d53d3",
  #            "href": "/v1/snitches/c2354d53d3",
  #            "name": "Daily Backups",
  #            "tags": [
  #              "production",
  #              "critical"
  #            ],
  #            "status": "pending",
  #            "checked_in_at": "",
  #            "type": {
  #              "interval": "daily"
  #            },
  #            "check_in_url" => "https://s.nosnch.in/c2354d53d3",
  #            "created_at" => "2015-08-15T12:15:00.234Z",
  #            "notes" => "Important user data."
  #          }
  #        ]
  def snitch(token)
    get "/snitches/#{token}"
  end

  # Public: Retrieve snitches that match all of the tags in a list
  #
  # tags - An array of strings. Each string is a tag.
  #
  # Examples
  #
  #   Get the snitches that match a list of tags
  #     @client.tagged_snitches(["production","critical"])
  #     => [
  #          {
  #            "token": "c2354d53d3",
  #            "href": "/v1/snitches/c2354d53d3",
  #            "name": "Daily Backups",
  #            "tags": [
  #              "production",
  #              "critical"
  #            ],
  #            "status": "pending",
  #            "checked_in_at": "",
  #            "type": {
  #              "interval": "daily"
  #            }
  #          },
  #          {
  #            "token": "c2354d53d4",
  #            "href": "/v1/snitches/c2354d53d4",
  #            "name": "Hourly Emails",
  #            "tags": [
  #              "production",
  #              "critical"
  #            ],
  #            "status": "healthy",
  #            "checked_in_at": "2014-01-01T12:00:00.000Z",
  #            "type": {
  #              "interval": "hourly"
  #            }
  #          }
  #        ]
  def tagged_snitches(tags=[])
    tag_params = strip_and_join_params(tags)

    get "/snitches?tags=#{tag_params}"
  end

  # Public: Create a snitch using passed-in values. Returns the new snitch.
  #
  # attributes - A hash of the snitch properties. It should include these keys:
  #              "name"     - String value is the name of the snitch.
  #              "interval" - String value representing how often the snitch
  #                           is expected to fire. Options are "hourly",
  #                           "daily", "weekly", and "monthly".
  #              "notes"    - Optional string value for recording additional
  #                           information about the snitch
  #              "tags"     - Optional array of string tags.
  #
  # Examples
  #
  #   Create a new snitch
  #     attributes = {
  #                     "name":     "Daily Backups",
  #                     "interval":  "daily",
  #                     "notes":    "Customer and supplier tables",
  #                     "tags":     ["backups", "maintenance"]
  #                  }
  #     @client.create_snitch(attributes)
  #     => [
  #          {
  #            "token": "c2354d53d3",
  #            "href": "/v1/snitches/c2354d53d3",
  #            "name": "Daily Backups",
  #            "tags": [
  #              "backups",
  #              "maintenance"
  #            ],
  #            "status": "pending",
  #            "checked_in_at": "",
  #            "type": {
  #              "interval": "daily"
  #            },
  #            "check_in_url": "https://s.nosnch.in/c2354d53d3",
  #            "created_at"=>"2015-08-27T18:30:23.737Z",
  #            "notes": "Customer and supplier tables"
  #          }
  #        ]
  def create_snitch(attributes={})
    post("/snitches", data_json(attributes))
  end

  # Public: Edit an existing snitch, identified by token, using passed-in
  #         values. Only changes those values included in the attributes
  #         hash; other attributes are not changed. Returns the updated snitch.
  #
  # token -       The unique token of the snitch to get. Should be a string.
  # attributes -  A hash of the snitch properties. It should only include those
  #               values you want to change. Options include these keys:
  #               "name"     - String value is the name of the snitch.
  #               "interval" - String value representing how often the snitch
  #                            is expected to fire. Options are "hourly",
  #                            "daily", "weekly", and "monthly".
  #               "notes"    - Optional string value for recording additional
  #                            information about the snitch
  #               "tags"     - Optional array of string tags.
  #
  # Examples
  #
  #   Edit an existing snitch using values passed in a hash.
  #     token      = "c2354d53d2"
  #     attributes = {
  #                     "name":     "Monthly Backups",
  #                     "interval": "monthly"
  #                  }
  #     @client.edit_snitch(token, attributes)
  #     => [
  #          {
  #            "token": "c2354d53d2",
  #            "href": "/v1/snitches/c2354d53d2",
  #            "name": "Monthly Backups",
  #            "tags": [
  #              "backups",
  #              "maintenance"
  #            ],
  #            "status": "pending",
  #            "checked_in_at": "",
  #            "type": {
  #              "interval": "monthly"
  #            },
  #            "notes": "Customer and supplier tables"
  #          }
  #        ]
  def edit_snitch(token, attributes={})
    patch("/snitches/#{token}", data_json(attributes))
  end

  # Public: Add one or more tags to an existing snitch, identified by token.
  #         Returns an array of the snitch's tags.
  #
  # token - The unique token of the snitch to edit. Should be a string.
  # tags -  Array of string tags. Will append these tags to any existing tags.
  #
  # Examples
  #
  #   Add tags to an existing snitch.
  #     token = "c2354d53d2"
  #     tags =  [ "red", "green" ]
  #     @client.add_tags(token, tags)
  #     => [
  #           "red",
  #           "green"
  #        ]
  def add_tags(token, tags=[])
    post("/snitches/#{token}/tags", tags)
  end

  # Public: Remove a tag from an existing snitch, identified by token.
  #         Returns an array of the snitch's tags.
  #
  # token - The unique token of the snitch to edit. Should be a string.
  # tag -   Tag to be removed from a snitch's tags. Should be a string.
  #
  # Examples
  #
  #   Assume a snitch that already has the tags "critical" and "production"
  #     token = "c2354d53d2"
  #     tag =   "production"
  #     @client.remove_tag(token, tag)
  #     => [
  #           "critical"
  #        ]
  def remove_tag(token, tag)
    delete("/snitches/#{token}/tags/#{tag}")
  end

  # Public: Replace all of a snitch's tags with those supplied.
  #         Returns the updated snitch.
  #
  # token - The unique token of the snitch to edit. Should be a string.
  # tags -  Array of string tags. Will replace the snitch's current tags with
  #         these.
  #
  # Examples
  #
  #   Assume a snitch with the tag "critical". Replace with tags provided.
  #     token = "c2354d53d3"
  #     tags =  ["production", "urgent"]
  #     @client.replace_tags(token, tags)
  #     => [
  #          {
  #            "token": "c2354d53d3",
  #            "href": "/v1/snitches/c2354d53d3",
  #            "name": "Daily Backups",
  #            "tags": [
  #              "production",
  #              "urgent"
  #            ],
  #            "status": "pending",
  #            "checked_in_at": "",
  #            "type": {
  #              "interval": "daily"
  #            },
  #            "notes": "Customer and supplier tables"
  #          }
  #        ]
  def replace_tags(token, tags=[])
    attributes = {"tags": tags}

    edit_snitch(token, attributes)
  end

  # Public: Pauses a snitch. The return is a hash with the message "Response
  #         complete".
  #
  # token - The unique token of the snitch to pause. Should be a string.
  #
  # Examples
  #
  #   Pause a snitch.
  #     token = "c2354d53d3"
  #     @client.pause_snitch(token)
  #     => { :message => "Response complete" }
  def pause_snitch(token)
    post("/snitches/#{token}/pause")
  end

  # Public: Deletes a snitch. The return is a hash with the message "Response
  #         complete".
  #
  # token - The unique token of the snitch to delete. Should be a string.
  #
  # Examples
  #
  #   Delete a snitch.
  #     token = "c2354d53d3"
  #     @client.delete_snitch(token)
  #     => { :message => "Response complete" }
  def delete_snitch(token)
    delete("/snitches/#{token}")
  end

  private

  def data_json(attributes={})
    JSON.generate(data_hash(attributes))
  end

  def data_hash(attributes={})
    attr_hash = Hash.new
    attr_hash["name"] = attributes[:name] if attributes.has_key?(:name)
    attr_hash["notes"] = attributes[:notes] if attributes.has_key?(:notes)
    attr_hash["tags"] = attributes[:tags] if attributes.has_key?(:tags)
    if attributes.has_key?(:interval)
      attr_hash["type"] = {"interval": attributes[:interval]}
    end
    attr_hash
  end

  def set_uri_and_path(path)
    uri     = @api_endpoint.dup
    # Given path will be relative to the api endpoint.
    path    = "/#{uri.path}/#{path}".gsub(/\/+/, "/")
    return uri, path
  end

  def strip_and_join_params(params)
    good_params = params.map { |p| p.strip }
    good_params.compact.uniq.join(",")
  end

  def initialize_opts(options, uri)
    timeout = options.fetch(:timeout, 5)

    {
      open_timeout: timeout,
      read_timeout: timeout,
      ssl_timeout:  timeout,
      use_ssl:      use_ssl?(uri)
    }
  end

  def use_ssl?(uri)
    uri.scheme == "https"
  end

  def user_agent
    # RUBY_ENGINE was not added until 1.9.3
    engine = defined?(::RUBY_ENGINE) ? ::RUBY_ENGINE : "Ruby"

    "Snitcher; #{engine}/#{RUBY_VERSION}; #{RUBY_PLATFORM}; v#{::Snitcher::VERSION}"
  end

  def set_up_authorization(request)
    unless @api_key.nil?
      request["Authorization"] = authorization
    else
      request.basic_auth @username, @password
    end
  end

  def authorization
    "Basic #{Base64.strict_encode64("#{@api_key}:")}"
  end

  def execute_request(http, request)
    set_up_authorization(request)
    response = http.request(request)
    evaluate_response(response)
  end

  def evaluate_response(response)
    case response
    when Net::HTTPNoContent
      { message: "Response complete" }
    when Net::HTTPSuccess
      JSON.parse(response.body)
    when Net::HTTPForbidden
      { message: "Unauthorized access" }
    when Net::HTTPUnprocessableEntity
      { message: "Unprocessable - #{response.body}"}
    else
      { message: "Response unsuccessful", response: response }
    end
  end

  def get(path, options={})
    uri, path = set_uri_and_path(path)
    http_options = initialize_opts(options, uri)

    Net::HTTP.start(uri.host, uri.port, http_options) do |http|
      request = Net::HTTP::Get.new(path)
      request["User-Agent"] = user_agent
      execute_request(http, request)
    end
  rescue Timeout::Error
    { message: "Request timed out" }
  end

  def post(path, data={}, options={})
    uri, path = set_uri_and_path(path)
    http_options = initialize_opts(options, uri)

    Net::HTTP.start(uri.host, uri.port, http_options) do |http|
      request = Net::HTTP::Post.new(path)
      request.body = "#{data}"
      request["User-Agent"] = user_agent
      request["Content-Type"] = "application/json"
      execute_request(http, request)
    end
  rescue Timeout::Error
    { message: "Request timed out" }
  end

  def patch(path, data, options={})
    uri, path = set_uri_and_path(path)
    http_options = initialize_opts(options, uri)

    Net::HTTP.start(uri.host, uri.port, http_options) do |http|
      request = Net::HTTP::Patch.new(path)
      request.body = data
      request["User-Agent"] = user_agent
      request["Content-Type"] = "application/json"
      execute_request(http, request)
    end
  rescue Timeout::Error
    { message: "Request timed out" }
  end

  def delete(path, options={})
    uri, path = set_uri_and_path(path)
    http_options = initialize_opts(options, uri)

    Net::HTTP.start(uri.host, uri.port, http_options) do |http|
      request = Net::HTTP::Delete.new(path)
      request["User-Agent"] = user_agent
      request["Content-Type"] = "application/json"
      execute_request(http, request)
    end
  rescue Timeout::Error
    { message: "Request timed out" }
  end
end
