require 'rails_helper'

photofile = FactoryGirl::build(:photofile)

RSpec.describe Photofile, type: :model do
  it "has a valid factory" do
    expect(photofile).to be_valid
  end
end
