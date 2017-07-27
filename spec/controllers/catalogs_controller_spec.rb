require 'rails_helper'
require "rack/test"
include Rack::Test::Methods

RSpec.describe Api::CatalogsController, type: :controller do

  it "returns 401 - not auth" do
    #setup

    #execute
    get :index, :format => :json

    # verify
    expect(response).to have_http_status(401)
  end

  it "returns all catalogs" do
    #setup
    FactoryGirl.create_list(:master_catalog, 10)
    request.headers.merge! authenticated_header()

    #execute
    get :index, :format => :json
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response.count).to eq(10)
  end

  it "returns no catalogs" do
    #setup
    request.headers.merge! authenticated_header()

    #execute
    get :index, :format => :json
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response.count).to be_zero
  end

  it "returns a single catalog" do
    #setup
    catalog = FactoryGirl.create(:master_catalog, id: 2)
    request.headers.merge! authenticated_header()

    #execute
    get :show, {:format => :json, params:{:id => 2}}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response["name"]).to eq(catalog.name)
    expect(parsed_response["id"]).to eq(catalog.id)
  end

  it "does not return a non-existing catalog " do
    #setup
    request.headers.merge! authenticated_header()

    #execute
    get :show, {:format => :json, params:{:id => -1}}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to have_http_status(404)
  end

  it "updates a catalog" do
    #setup
    catalog = FactoryGirl.create(:master_catalog, id: 2)
    request.headers.merge! authenticated_header()

    #execute
    changes = {id: 2, catalog: {name: "new name"}}
    put :update, {:format => :json, params: changes}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response["name"]).to eq(changes[:catalog][:name])
  end

  it "creates a MasterCatalog" do
    #setup
    request.headers.merge! authenticated_header()
    new_catalog_json = {:name => "Catalog new", :type => "MasterCatalog"}

    #execute
    post :create, {:format => :json, params: {catalog: new_catalog_json }}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response["name"]).to eq(new_catalog_json[:name])
    expect(parsed_response["type"]).to eq(new_catalog_json[:type])
    expect(parsed_response["id"]).to be > 0
  end

  it "creates a DropboxCatalog" do
    #setup
    request.headers.merge! authenticated_header()
    new_catalog_json = {:name => "Catalog new", :type => "DropboxCatalog"}

    #execute
    post :create, {:format => :json, params: {catalog: new_catalog_json }}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response["name"]).to eq(new_catalog_json[:name])
    expect(parsed_response["type"]).to eq(new_catalog_json[:type])
    expect(parsed_response).to include("auth_url")
    expect(parsed_response["id"]).to be > 0
  end

  it "creates a FlickrCatalog" do
    #setup
    request.headers.merge! authenticated_header()
    new_catalog_json = {:name => "Catalog new", :type => "FlickrCatalog"}

    #execute
    post :create, {:format => :json, params: {catalog: new_catalog_json }}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response["name"]).to eq(new_catalog_json[:name])
    expect(parsed_response["type"]).to eq(new_catalog_json[:type])
    expect(parsed_response).to include("auth_url")
    expect(parsed_response["id"]).to be > 0
  end

  it "deletes a catalog" do
    #setup
    request.headers.merge! authenticated_header()
    new_catalog = FactoryGirl.create(:master_catalog)

    #execute
    post :destroy, {:format => :json, params: { id: new_catalog.id }}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response["id"]).to eq(new_catalog.id)
  end

  it "imports to a catalog" do
    #setup
    request.headers.merge! authenticated_header()
    new_catalog = FactoryGirl.create(:master_catalog)

    #execute
    get :import, {:format => :json, params: { id: new_catalog.id }}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response["response"]["job_id"]).not_to be_empty
  end





end
