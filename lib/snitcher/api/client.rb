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
  #   api_endpoint: 
  def initialize(options = {})
    @api_key      = options[:api_key]
    #@api_endpoint = URI.parse("https://api.deadmanssnitch.com/api/v1/")
    @api_endpoint = URI.parse("http://api.dms.dev:3000/v1/")
  end

  def get(path, options = {})
    uri     = @api_endpoint.dup
    # Given path will be relative to the api endpoint.
    path    = "/#{uri.path}/#{path}".gsub(/\/+/, "/")
    timeout = options.fetch(:timeout, 5)

    http_options = {
      # Configure all the timeouts
      open_timeout: timeout,
      read_timeout: timeout,
      ssl_timeout:  timeout,

      # Enable HTTPS if necessary
      use_ssl:      uri.scheme == "https",
    }

    Net::HTTP.start(uri.host, uri.port, http_options) do |http|
      # Set up the request
      request = Net::HTTP::Get.new(path)
      request["User-Agent"]    = user_agent
      request["Authorization"] = authorization

      pp path
      pp request

      response = http.request(request)
      pp response

      case response
      when Net::HTTPSuccess
        # Yeah!
        JSON.parse(response.body)
      else
        # BOO!
      end
    end
  end

  # Public: List snitches on the account
  #
  # Examples
  #
  #   Get a list of all snitches
  #   Snitcher::API.snitches
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
  #   Snitcher::API.snitch("c2354d53d2")
  def snitch(token)
    get "/snitches/#{token}"
  end

  def create_snitch(attributes)
  end

  def delete_snitch(token)
  end

  private 

  def user_agent
    # RUBY_ENGINE was not added until 1.9.3
    engine = defined?(::RUBY_ENGINE) ? ::RUBY_ENGINE : "Ruby"

    "Snitcher; #{engine}/#{RUBY_VERSION}; #{RUBY_PLATFORM}; v#{::Snitcher::VERSION}"
  end

  def authorization
    "Basic #{Base64.strict_encode64("#{@api_key}:")}"
  end
end
