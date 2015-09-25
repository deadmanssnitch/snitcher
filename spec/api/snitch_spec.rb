require "spec_helper"
require "snitcher/api"
require "snitcher/api/snitch"

describe Snitcher::API::Snitch do
  describe "#new" do
    before do
      payload = {
                  "token" => "c2354d53d3",
                  "name" => "Daily Backups",
                  "type" => {
                    "interval" => "daily"
                  },
                  "notes" => "Important user data."
                }
      @snitch = Snitcher::API::Snitch.new(payload)
    end

    it "returns a Snitch object" do
      expect(@snitch).to be_a(Snitcher::API::Snitch)
    end

    it "sets appropriate values" do
      expect(@snitch.name).to eq("Daily Backups")
      expect(@snitch.token).to eq("c2354d53d3")
      expect(@snitch.notes).to eq("Important user data.")
      expect(@snitch.interval).to eq("daily")
    end
  end
end