require 'rails_helper'

photo = FactoryGirl::build(:photo)

RSpec.describe Photo, type: :model do
  it "has a valid factory" do
    expect(photo).to be_valid
  end
end
