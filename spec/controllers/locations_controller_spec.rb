require 'rails_helper'
require "rack/test"
include Rack::Test::Methods

RSpec.describe Api::LocationsController, type: :controller do

  it "location returns 401 - not auth" do
    #setup

    #execute
    get :index, :format => :json

    # verify
    expect(response).to have_http_status(401)
  end

  it "returns all countries" do
    #setup
    FactoryGirl.create_list(:country, 4)
    request.headers.merge! authenticated_header()

    #execute
    get :countries, :format => :json
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response.count).to eq(4)
  end

  it "returns all cities" do
    #setup
    FactoryGirl.create_list(:city, 4)
    request.headers.merge! authenticated_header()

    #execute
    get :cities, :format => :json
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response.count).to eq(4)
  end
end
