class Snitcher::API::Snitch
  attr_accessor :token, :name, :tags, :status, :checked_in_at,
    :interval, :check_in_url, :created_at, :notes

  # Public: Return a Snitcher::API::Snitch object based on a hash payload.
  #
  # Example
  #
  #   payload = {
  #     "token" => "c2354d53d3",
  #     "href" => "/v1/snitches/c2354d53d3",
  #     "name" => "Daily Backups",
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
  #   => #<Snitcher::API::Snitch:0x007fdcf50ad2d0 @token="c2354d53d3",
  #       @name="Daily Backups", @tags=["production", "critical"],
  #       @status="pending", @checked_in_at=nil, @interval="daily",
  #       @check_in_url="https://nosnch.in/c2354d53d3",
  #       @created_at="2015-08-15T12:15:00.234Z", @notes="Important user data.">
  def initialize(payload)
    @token = payload["token"]
    @name = payload["name"]
    @tags = payload["tags"]
    @status = payload["status"]
    @checked_in_at = payload["checked_in_at"]
    @interval = payload["type"]["interval"]
    @check_in_url = payload["check_in_url"]
    @created_at = payload["created_at"]
    @notes = payload["notes"]
  end
end
