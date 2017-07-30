require 'rails_helper'
require "rack/test"
include Rack::Test::Methods

RSpec.describe Api::PhotosController, type: :controller do

  before(:context) do
    @header = authenticated_header()
    _photos = FactoryGirl.create_list(:photo, 3)
    @photo = _photos.first
    @photo_with_facets = _photos.last
    @photo_with_facets.add_bucket User.last
    @photo_with_facets.add_like User.last
    @photo_with_facets.add_tag User.last, "my_tag"
    @photo_with_facets.add_comment User.last, "a comment"
  end

  it "returns 401 - not auth" do
    #execute
    get :index, :format => :json

    # verify
    expect(response).to have_http_status(401)
  end

  it "returns all photos" do
    #setup
    request.headers.merge! @header

    #execute
    get :index, :format => :json, params: {:startdate =>  Date.today}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json.count).to eq(3)
  end

  it "returns one photo" do
    #setup
    request.headers.merge! @header

    #execute
    get :show, :format => :json, params: {:id => @photo_with_facets.id }
    json = JSON.parse(response.body)
    p json

    # verify
    expect(response).to be_success
  end


  it "bucket a photo" do
    #setup
    request.headers.merge! @header

    #execute
    get :bucket, :format => :json, params: {:id => @photo.id}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["bucket"]["type"]).to eq("Bucket")
  end

  it "Unbucket a photo" do
    #setup
    request.headers.merge! @header

    #execute
    get :unbucket, :format => :json, params: {:id => @photo_with_facets.id}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["bucket"]).to be_nil
  end

  it "Add like to photo" do
    #setup
    request.headers.merge! @header

    #execute
    get :like, :format => :json, params: {:id => @photo.id}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["like"]["type"]).to eq("Like")
  end

  it "Unlike a photo" do
    #setup
    request.headers.merge! @header

    #execute
    get :unlike, :format => :json, params: {:id => @photo_with_facets.id}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["like"]).to be_nil
  end

  it "add comment to photo" do
    #setup
    request.headers.merge! @header

    #execute
    get :comment, :format => :json, params: {:id => @photo.id, :comment => "this is it!"}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["comments"].first["type"]).to eq("Comment")
  end

  it "Remove comment to photo" do
    #setup
    request.headers.merge! @header

    #execute
    get :uncomment, :format => :json, params: {
      :id => @photo_with_facets.id,
      :comment_id => @photo_with_facets.comments.first.id
     }
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["comments"]).to be_empty
  end

  it "add tag to photo" do
    #setup
    request.headers.merge! @header

    #execute
    get :tag, :format => :json, params: {:id => @photo.id, :tag => "duddi"}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["tags"].first["type"]).to eq("Tag")
  end

  it "Remove tag from photo" do
    #setup
    request.headers.merge! @header

    #execute
    get :untag, :format => :json, params: {
      :id => @photo_with_facets.id,
      :tag_id => @photo_with_facets.tags.first.id
     }
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["tags"]).to be_empty
  end

  it "Get full tag list" do
    #setup
    request.headers.merge! @header

    #execute
    get :tags, :format => :json, params: { }
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
  end


end
