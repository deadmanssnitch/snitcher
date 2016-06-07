require "snitcher"
require "net/https"
require "json"

require "timeout"
require "snitcher/version"

module Snitcher
  module API
    # Snitcher::API::Error and subclasses
    require "snitcher/api/error"
  end
end

require "snitcher/api/client"
