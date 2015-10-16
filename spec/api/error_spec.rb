describe Snitcher::API::Error do
  it "returns a AuthenticationError for 'sign_in_incorrect'" do
    error = Snitcher::API::Error.new("sign_in_incorrect", "Oh noes!")

    expect(error).to be_a(Snitcher::API::AuthenticationError)
    expect(error.message).to eq("Oh noes!")
  end

  it "returns a base Error for unknown type" do
    error = Snitcher::API::Error.new("not_documented", "Oh noes!")

    expect(error).to be_a(Snitcher::API::Error)
    expect(error.message).to eq("Oh noes!")
  end
end
