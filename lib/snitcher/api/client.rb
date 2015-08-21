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
    # @api_endpoint = URI.parse("https://api.deadmanssnitch.com/v1/")
    ## Use in development for testing
    @api_endpoint = URI.parse("http://api.dms.dev:3000/v1/")
  end

  def get(path, options = {})
    uri     = @api_endpoint.dup
    # Given path will be relative to the api endpoint.
    path    = "/#{uri.path}/#{path}".gsub(/\/+/, "/")

    http_options = initialize_opts(options, uri)

    Net::HTTP.start(uri.host, uri.port, http_options) do |http|
      # Set up the request
      request = Net::HTTP::Get.new(path)
      request["User-Agent"] = user_agent

      set_up_authorization(request, options)

      # pp path
      # pp request

      response = http.request(request)
      # pp response

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      when Net::HTTPForbidden
        { message: "Unauthorized access" }
      else
        { message: "Response unsuccessful", response: response }
      end
    end
  rescue Timeout::Error
    { message: "Request timed out" }
  end

  # Public: Retrieve API key based on username and password
  #
  # username - The username associated with a Deadman's Snitch account
  # password - The password associated with a Deadman's Snitch account
  #
  # Examples
  #
  #   Get the api_key for user alice@example.com
  #     @client.api_key("alice@example.com", "password")
  #     => {
  #           "api_key" => "_caeEiZXnEyEzXXYVh2NhQ"
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
  #            "token": "c2354d53d2",
  #            "href": "/v1/snitches/c2354d53d2",
  #            "name": "Daily Backups",
  #            "tags": [
  #              "production",
  #              "critical"
  #            ],
  #            "status": "pending",
  #            "checked_in_at": "2014-01-01T12:00:00.000Z",
  #            "type": {
  #              "interval": "daily"
  #            }
  #          },
  #          {
  #            "token": "c2354d53d2",
  #            "href": "/v1/snitches/c2354d53d2",
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
  # token - The unique token of the snitch to get
  #
  # Examples
  #
  #   Get the snitch with token "c2354d53d2"
  #     @client.snitch("c2354d53d2")
  def snitch(token)
    get "/snitches/#{token}"
  end

  def create_snitch(attributes)
  end

  def delete_snitch(token)
  end

  private 

  def initialize_opts(options, uri)
    timeout = options.fetch(:timeout, 5)

    {
      # Configure all the timeouts
      open_timeout: timeout,
      read_timeout: timeout,
      ssl_timeout:  timeout,

      # Enable HTTPS if necessary
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

  def set_up_authorization(request, options)
    unless @api_key.nil?
      request["Authorization"] = authorization
    else
      request.basic_auth @username, @password
    end
  end

  def authorization
    "Basic #{Base64.strict_encode64("#{@api_key}:")}"
  end
end
