require 'rails_helper'
require "rack/test"
include Rack::Test::Methods

RSpec.describe Api::PhotosController, type: :controller do

  it "returns 401 - not auth" do
    #setup

    #execute
    get :index, :format => :json

    # verify
    expect(response).to have_http_status(401)
  end

  it "returns all photos" do
    #setup
    request.headers.merge! authenticated_header()
    p = FactoryGirl.create_list(:photo, 3)

    #execute
    get :index, :format => :json, params: {:startdate =>  Date.today}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    # expect(parsed_response.count).to eq(3)
  end

  it "returns all photos, one in bucket" do
    #setup
    request.headers.merge! authenticated_header()
    p1 = FactoryGirl.create(:photo)
    p2 = FactoryGirl.create(:photo )
    Bucket.create( photo: p2, user: User.first)

    #execute
    get :index, :format => :json, params: {:startdate =>  Date.today}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    p1_json = parsed_response.select {|p| p["id"] == p1.id }
    p2_json = parsed_response.select {|p| p["id"] == p2.id }
    puts p2_json
    expect(p1_json.first["bucket"]).to be_falsy
    expect(p2_json.first["bucket"]).to be_truthy
  end



  it "returns all tags" do
    #setup
    photo = FactoryGirl.create(:photo)
    photo.tag_list.add "my_tag_1"
    photo.tag_list.add "my_tag_2"
    photo.save
    request.headers.merge! authenticated_header()

    #execute
    get :taglist, :format => :json
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response.count).to eq(2)
  end

  it "returns one photo with tags" do
    #setup
    request.headers.merge! authenticated_header()
    p = FactoryGirl.create(:photo)
    p.tag_list = "awesome, slick, hefty"
    p.save

    #execute
    get :show, :format => :json, params: {:id =>  p.id}
    parsed_response = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(parsed_response["tags"].size).to eq(3)
  end

  it "returns one photo which is liked" do
    #setup
    request.headers.merge! authenticated_header()
    p = FactoryGirl.create(:photo)
    p.liked_by User.last


    #execute
    get :show, :format => :json, params: {:id =>  p.id}
    parsed_response = JSON.parse(response.body)
    byebug
    # verify
    expect(response).to be_success
    expect(parsed_response["tags"].size).to eq(3)
  end

  # it "returns no albums" do
  #   #setup
  #   request.headers.merge! authenticated_header()
  #
  #   #execute
  #   get :index, :format => :json
  #   parsed_response = JSON.parse(response.body)
  #
  #   # verify
  #   expect(response).to be_success
  #   expect(parsed_response.count).to be_zero
  # end
  #
  # it "returns a single album" do
  #   #setup
  #   album = FactoryGirl.create(:album, id: 2)
  #   request.headers.merge! authenticated_header()
  #
  #   #execute
  #   get :show, {:format => :json, params:{:id => 2}}
  #   parsed_response = JSON.parse(response.body)
  #
  #   # verify
  #   expect(response).to be_success
  #   expect(parsed_response["name"]).to eq(album.name)
  #   expect(parsed_response["id"]).to eq(album.id)
  #   # expect(parsed_response["country"]).to eq(album.country)
  # end
  #
  # it "does not return a non-existing album " do
  #   #setup
  #   request.headers.merge! authenticated_header()
  #
  #   #execute
  #   get :show, {:format => :json, params:{:id => -1}}
  #   parsed_response = JSON.parse(response.body)
  #
  #   # verify
  #   expect(response).to have_http_status(404)
  # end
  #
  # it "updates an album" do
  #   #setup
  #   album = FactoryGirl.create(:album, id: 2)
  #   request.headers.merge! authenticated_header()
  #
  #   #execute
  #   changes = {id: 2, album: {name: "new name"}}
  #   put :update, {:format => :json, params: changes}
  #   parsed_response = JSON.parse(response.body)
  #
  #   # verify
  #   expect(response).to be_success
  #   expect(parsed_response["name"]).to eq(changes[:album][:name])
  # end
  #
  # it "creates an album" do
  #   #setup
  #   request.headers.merge! authenticated_header()
  #   new_album = FactoryGirl.build(:album)
  #
  #   #execute
  #   post :create, {:format => :json, params: { album: new_album.as_json }}
  #   parsed_response = JSON.parse(response.body)
  #
  #   # verify
  #   expect(response).to be_success
  #   expect(parsed_response["name"]).to eq(new_album.name)
  #   expect(parsed_response["id"]).to be > 0
  #   # expect(parsed_response["country"]).to eq(new_album.country)
  # end
  #
  # it "deletes an album" do
  #   #setup
  #   request.headers.merge! authenticated_header()
  #   new_album = FactoryGirl.create(:album)
  #
  #   #execute
  #   post :destroy, {:format => :json, params: { id: new_album.id }}
  #   parsed_response = JSON.parse(response.body)
  #
  #   # verify
  #   expect(response).to be_success
  #   expect(parsed_response["id"]).to eq(new_album.id)
  #   # expect(parsed_response["country"]).to eq(new_album.country)
  # end

end
