require 'rails_helper'
require "rack/test"
include Rack::Test::Methods

RSpec.describe API::PhotosController, type: :controller do

  before(:context) do
    @header = authenticated_header()
    _photos = FactoryGirl.create_list(:photo, 3)
    @photo = _photos.first
    @photo_with_facets = _photos.last
    @photo_with_facets.bucket_toggle User.last
    @photo_with_facets.like_toggle User.last
    @photo_with_facets.add_tag User.last, "my_tag"
    @photo_with_facets.add_comment User.last, "a comment which is rather long"
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

    # verify
    expect(response).to be_success
  end


  it "bucket a photo" do
    #setup
    request.headers.merge! @header

    #execute
    post :bucket_toggle, :format => :json, params: {:id => @photo.id}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["bucket"]["type"]).to eq("Bucket")
  end

  it "Unbucket a photo" do
    #setup
    request.headers.merge! @header

    #execute
    post :bucket_toggle, :format => :json, params: {:id => @photo_with_facets.id}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["bucket"]).to be_nil
  end

  it "get bucket" do
    #setup
    request.headers.merge! @header

    #execute
    post :bucket, :format => :json, params: {:id => @photo.id}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    # expect(json["bucket"]["type"]).to eq("Bucket")
  end

  it "Add like to photo" do
    #setup
    request.headers.merge! @header

    #execute
    post :like_toggle, :format => :json, params: {:id => @photo.id}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["like"]["type"]).to eq("Like")
  end

  it "Unlike a photo" do
    #setup
    request.headers.merge! @header

    #execute
    delete :like_toggle, :format => :json, params: {:id => @photo_with_facets.id}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["like"]).to be_nil
  end

  it "add comment to photo" do
    #setup
    request.headers.merge! @header

    #execute
    post :comment, :format => :json, params: {:id => @photo.id, :comment => "this is it!"}
    json = JSON.parse(response.body)
    p json
    # verify
    expect(response).to be_success
    expect(json["comments"].first["type"]).to eq("Comment")
  end

  it "Remove comment to photo" do
    #setup
    request.headers.merge! @header

    #execute
    delete :uncomment, :format => :json, params: {
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
    post :tag, :format => :json, params: {:id => @photo.id, :tag => "duddi"}
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
    expect(json["tags"].first["type"]).to eq("Tag")
  end

  it "Remove tag from photo" do
    #setup
    request.headers.merge! @header

    #execute
    delete :untag, :format => :json, params: {
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
    get :taglist, :format => :json, params: { }
    json = JSON.parse(response.body)

    # verify
    expect(response).to be_success
  end


end
