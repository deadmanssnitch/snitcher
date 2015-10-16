require "pp"

require "net/https"
require "timeout"
require "base64"
require "json"

require "snitcher/version"

class Snitcher::API::Base
  def set_uri_path_and_options(path, options)
    uri     = @api_endpoint.dup
    path    = "/#{uri.path}/#{path}".gsub(/\/+/, "/")
    opts    = initialize_opts(options, uri)
    return uri, path, opts
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
    request["Authorization"] = "Basic #{Base64.strict_encode64("#{@api_key}:")}"
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

  def data_json(attributes={})
    JSON.generate(data_hash(attributes))
  end

  def data_hash(attributes={})
    attr_hash = Hash.new
    attr_hash["name"] = attributes[:name] if attributes.has_key?(:name)
    attr_hash["notes"] = attributes[:notes] if attributes.has_key?(:notes)
    attr_hash["tags"] = attributes[:tags] if attributes.has_key?(:tags)
    if attributes.has_key?(:interval)
      attr_hash["type"] = {
        "interval" => attributes[:interval],
      }
    end
    attr_hash
  end

  def strip_and_join_params(params)
    good_params = params.map { |p| p.strip }
    good_params.compact.uniq.join(",")
  end

  def set_agent(request)
    request["User-Agent"] = user_agent
  end

  def set_agent_and_type(request, type)
    set_agent(request)
    request["Content-Type"] = "application/#{type}"
  end

  def timeout_message
    { message: "Request timed out" }
  end

  ## HTTP Requests Below

  def get(path, options={})
    uri, path, http_options = set_uri_path_and_options(path, options)

    Net::HTTP.start(uri.host, uri.port, http_options) do |http|
      request = Net::HTTP::Get.new(path)
      set_agent(request)
      execute_request(http, request)
    end
  rescue Timeout::Error
    timeout_message
  end

  def post(path, data={}, options={})
    uri, path, http_options = set_uri_path_and_options(path, options)

    Net::HTTP.start(uri.host, uri.port, http_options) do |http|
      request = Net::HTTP::Post.new(path)
      request.body = "#{data}"
      set_agent_and_type(request, "json")
      execute_request(http, request)
    end
  rescue Timeout::Error
    timeout_message
  end

  def patch(path, data, options={})
    uri, path, http_options = set_uri_path_and_options(path, options)

    Net::HTTP.start(uri.host, uri.port, http_options) do |http|
      request = Net::HTTP::Patch.new(path)
      request.body = data
      set_agent_and_type(request, "json")
      execute_request(http, request)
    end
  rescue Timeout::Error
    timeout_message
  end

  def delete(path, options={})
    uri, path, http_options = set_uri_path_and_options(path, options)

    Net::HTTP.start(uri.host, uri.port, http_options) do |http|
      request = Net::HTTP::Delete.new(path)
      set_agent_and_type(request, "json")
      execute_request(http, request)
    end
  rescue Timeout::Error
    timeout_message
  end
end
