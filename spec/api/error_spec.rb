require "spec_helper"
require "snitcher/api"

RSpec.describe Snitcher::API::Error do
  it "returns a AuthenticationError for 'sign_in_incorrect'" do
    error = Snitcher::API::Error.new({
      "type"  => "sign_in_incorrect",
      "error" => "Oh noes!",
    })

    expect(error).to be_a(Snitcher::API::AuthenticationError)
    expect(error.message).to eq("Oh noes!")
  end

  it "returns a base Error for unknown type" do
    error = Snitcher::API::Error.new({
      "type"  => "not_documented",
      "error" => "Oh noes!",
    })

    expect(error).to be_a(Snitcher::API::Error)
    expect(error.message).to eq("Oh noes!")
  end

  it "returns AuthenticationError for an 'api_key_invalid'" do
    error = Snitcher::API::Error.new({
      "type"  => "api_key_invalid",
      "error" => "Not a valid key!!",
    })

    expect(error).to be_a(Snitcher::API::AuthenticationError)
    expect(error.message).to eq("Not a valid key!!")
  end

  it "returns PlanLimitReachedError for an 'plan_limit_reached'" do
    error = Snitcher::API::Error.new({
      "type"  => "plan_limit_reached",
      "error" => "Plan limit reached error!!",
    })

    expect(error).to be_a(Snitcher::API::PlanLimitReachedError)
    expect(error.message).to eq("Plan limit reached error!!")
  end

  it "returns AccountOnHoldError for an 'account_on_hold'" do
    error = Snitcher::API::Error.new({
      "type"  => "account_on_hold",
      "error" => "Pay us!!",
    })

    expect(error).to be_a(Snitcher::API::AccountOnHoldError)
    expect(error.message).to eq("Pay us!!")
  end

  it "returns ResourceNotFoundError for an 'resource_not_found'" do
    error = Snitcher::API::Error.new({
      "type"  => "resource_not_found",
      "error" => "I can't find that!!",
    })

    expect(error).to be_a(Snitcher::API::ResourceNotFoundError)
    expect(error.message).to eq("I can't find that!!")
  end
end
