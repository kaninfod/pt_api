require 'rails_helper'

user = FactoryGirl::build(:user)

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(user).to be_valid
  end
end
