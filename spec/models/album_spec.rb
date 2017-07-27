require 'rails_helper'

album = FactoryGirl::build(:album)

RSpec.describe Album, type: :model do
  it "has a valid factory" do
    expect(album).to be_valid
  end
end
