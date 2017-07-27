require 'rails_helper'

location = FactoryGirl::build(:location)
city = FactoryGirl::build(:city)
country = FactoryGirl::build(:country)

RSpec.describe Location, type: :model do
  it "has a valid factory" do
    expect(location).to be_valid
  end
end

RSpec.describe City, type: :model do
  it "has a valid factory" do
    expect(city).to be_valid
  end
end

RSpec.describe Country, type: :model do
  it "has a valid factory" do
    expect(country).to be_valid
  end
end
