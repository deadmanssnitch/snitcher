# frozen_string_literal: true

class Snitcher::API::Snitch
  # @return [String] unique token used to identify a Snitch.
  attr_accessor :token

  # @return [String] useful name for the Snitch to help identify it.
  attr_accessor :name

  # @return [Array<String>] list of tags on the Snitch.
  attr_accessor :tags

  # @return [String] the current reporting status of the Snitch. One of
  #   "pending", "healthy", "paused", "failed", or "errored".
  attr_accessor :status

  # alert_email is a list of email addresses that will be notified when this
  # Snitch goes missing, errors, or becomes healthy again. When this is set,
  # only the email addresses in the list will be notified. When the list is
  # empty then all team members will be alerted by default.
  #
  # @return [Array<String>] override list of email addresses
  attr_accessor :alert_email

  # @return [String] when the Snitch last checked_in
  attr_accessor :checked_in_at

  # @return [String] how often Dead Man's Snitch expects to hear from the
  #   Snitch. One of "15_minute", "30_minute", "hourly", "daily", "weekly", or
  #   "monthly".
  attr_accessor :interval

  # @return [String] url used to check-in in the Snitch as healthy.
  attr_accessor :check_in_url

  # @return [String] when the Snitch was created.
  attr_accessor :created_at

  # @return [String] generic notes for the Snitch. Useful for specifying actions
  #   to take when a Snitch stops reporting.
  attr_accessor :notes

  # Create a new Snitch from an API response.
  #
  # @example
  #   payload = {
  #     "token" => "c2354d53d3",
  #     "href" => "/v1/snitches/c2354d53d3",
  #     "name" => "Daily Backups",
  #     "alert_email" => [],
  #     "tags" => [
  #       "production",
  #       "critical"
  #     ],
  #     "status" => "pending",
  #     "checked_in_at" => "",
  #     "type": {
  #       "interval" => "daily"
  #     },
  #     "check_in_url" => "https://nosnch.in/c2354d53d3",
  #     "created_at" => "2015-08-15T12:15:00.234Z",
  #     "notes" => "Important user data.",
  #   }
  #
  #   Snitcher::API::Snitch.new(payload)
  #   # => #<Snitcher::API::Snitch...>
  #
  # @return Snitcher::API::Snitch
  def initialize(payload)
    @token     = payload["token"]
    @name      = payload["name"]
    @tags      = payload["tags"]
    @status    = payload["status"]
    @interval  = payload["type"]["interval"]
    @notes     = payload["notes"]

    @created_at    = payload["created_at"]
    @alert_email   = payload["alert_email"] || []
    @check_in_url  = payload["check_in_url"]
    @checked_in_at = payload["checked_in_at"]
  end
end
