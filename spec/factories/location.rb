

FactoryGirl.define do
  factory :location do
    # sequence :id      { |n| n }
    status            { Faker::Number.number(1) }
    latitude          { Faker::Number.between(1, 180) }
    longitude         { Faker::Number.between(1, 180) }
    location          { Faker::Address.state }
    state             { Faker::Address.state }
    address           { Faker::Address.street_address }
    road              { Faker::Address.street_name }
    suburb            { Faker::Address.city }
    postcode          { Faker::Address.zip_code }
    created_at        { Faker::Date.backward(14) }
    updated_at        { Faker::Date.backward(14) }
    map_image_id      { Faker::Number.number(2) }
    association         :city, factory: :city
    association         :country, factory: :country
  end
end

FactoryGirl.define do
  factory :country do
    # sequence :id      { |n| n }
    name              { Faker::Address.country }
  end
end

FactoryGirl.define do
  factory :city do
    # sequence :id      { |n| n }
    name              { Faker::Address.city }
  end
end
