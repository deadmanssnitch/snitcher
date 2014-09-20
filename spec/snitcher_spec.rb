require "spec_helper"

require "securerandom"

describe Snitcher do
  let(:token) { SecureRandom.hex(5) }

  before do
    stub_request(:get, /nosnch\.in/)
  end

  describe ".snitch" do
    it "pings DMS with the given token" do
      Snitcher.snitch(token)

      expect(a_request(:get, "https://nosnch.in/#{token}")).to have_been_made.once
    end

    context "when successful" do
      before do
        stub_request(:get, "https://nosnch.in/#{token}").to_return(status: 200)
      end

      it "returns true" do
        expect(Snitcher.snitch(token)).to eq(true)
      end
    end

    context "when unsuccessful" do
      before do
        stub_request(:get, "https://nosnch.in/#{token}").to_return(status: 404)
      end

      it "returns false" do
        expect(Snitcher.snitch(token)).to eq(false)
      end
    end

    describe "with message" do
      it "includes the message as a query param" do
        Snitcher.snitch(token, :message => "A thing just happened")

        expect(a_request(:get, "https://nosnch.in/#{token}?m=A%20thing%20just%20happened"))
      end
    end

    describe "timeout" do
      before do
        stub_request(:get, "https://nosnch.in/#{token}").to_raise(::Timeout::Error)
      end

      it "returns false when timed out" do
        expect(Snitcher.snitch(token)).to eq(false)
      end
    end
  end

  describe "inclusion" do
    let(:snitching_class) { Class.new { include Snitcher } }

    it "snitches" do
      snitching_class.new.snitch(token)

      expect(a_request(:get, "https://nosnch.in/#{token}")).to have_been_made.once
    end
  end

  describe "extension" do
    let(:snitching_class) { Class.new { extend Snitcher } }

    it "snitches" do
      snitching_class.snitch(token)

      expect(a_request(:get, "https://nosnch.in/#{token}")).to have_been_made.once
    end
  end
end
