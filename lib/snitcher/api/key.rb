require "pp"

require "net/https"
require "timeout"
require "base64"
require "json"

require "snitcher/api"
require "snitcher/api/base"
require "snitcher/version"

class Snitcher::API::Key < Snitcher::API::Base
  # Public: Create a new Key Access Agent
  #
  # options:
  #   username: the username associated with a Snitcher account
  #   password: the password associated with a Snitcher account
  #
  # Example
  #
  #     @client = Snitcher::API::Key.new({username: "alice@example.com",
  #       password: "password"})
  #     => #<Snitcher::API::Key:0x007fa3750af418 @username=nil,
  #          @password=nil, @api_endpoint=#<URI::HTTPS
  #          https://api.deadmanssnitch.com/v1/>>
  #
  def initialize(options = {})
    @username     = options[:username]
    @password     = options[:password]

    ## Use in production
    # @api_endpoint = URI.parse("https://api.deadmanssnitch.com/v1/")
    ## Use in development for testing
    @api_endpoint = URI.parse("http://api.dms.dev:3000/v1/")

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
  #     @agent = Snitcher::API::Key.new({username: "alice@example.com",
  #       password: "password"})
  #     @agent.api_key
  #     => {
  #          "api_key" => "_caeEiZXnEyEzXXYVh2NhQ"
  #        }
  #
  # When the request is unsuccessful, the endpoint returns a hash
  # with a message indicating the nature of the failure.
  def api_key
    get "/api_key"
  end
end
