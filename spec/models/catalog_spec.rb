require 'rails_helper'

master_catalog = FactoryGirl::build(:master_catalog)
dropbox_catalog = FactoryGirl::build(:dropbox_catalog)
flickr_catalog = FactoryGirl::build(:flickr_catalog)

RSpec.describe MasterCatalog, type: :model do
  it "master_catalog a valid factory" do
    expect(master_catalog).to be_valid
  end

  it "dropbox_catalog a valid factory" do
    expect(dropbox_catalog).to be_valid
  end

  it "flickr_catalog a valid factory" do
    expect(flickr_catalog).to be_valid
  end

end
