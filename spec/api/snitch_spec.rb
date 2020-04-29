require "spec_helper"
require "snitcher/api"
require "snitcher/api/snitch"

describe Snitcher::API::Snitch do
  describe "#new" do
    let(:snitch) do
      payload = {
        "token"       => "c2354d53d3",
        "name"        => "Daily Backups",
        "alert_email" => ["user@example.com"],
        "notes"       => "Important user data.",
        "type"        => {
          "interval" => "daily",
        },
      }

      Snitcher::API::Snitch.new(payload)
    end

    it "returns a Snitch object" do
      expect(snitch).to be_a(Snitcher::API::Snitch)
    end

    it "sets appropriate values" do
      expect(snitch.name).to eq("Daily Backups")
      expect(snitch.token).to eq("c2354d53d3")
      expect(snitch.notes).to eq("Important user data.")
      expect(snitch.interval).to eq("daily")
      expect(snitch.alert_email).to eq(["user@example.com"])
    end
  end
end
