require 'rails_helper'

# RSpec.describe Api::UsersController, type: :controller do
RSpec.describe Api::UsersController, type: [:request, :controller] do
  before(:context) do
    @header = authenticated_header()
    email, password = "user@mail.com", "123"
    FactoryGirl.create(:user, email: email, password: password)
  end

  it "login a user with success" do
    #execute
    post "/api/users/login",  params: { :email => 'user@mail.com', :password => '123' }
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json['email']).to eq("user@mail.com")
  end

  it "get a user from token" do
    #setup
    request.headers.merge! @header

    #execute
    get "/api/users/from_token", params: @header
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
  end

  it "login a user without success" do
    #setup
    # request.headers.merge! @header

    #execute
    post "/api/users/login",  params: { :email => 'user@mail.com', :password => '123xx' }
    json = JSON.parse(response.body)

    # verify
    expect(response).not_to be_success
  end

end
