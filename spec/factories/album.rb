
FactoryGirl.define do
  factory :album do
    # sequence :id      { |n| n }
    sequence :name    { |n| "person_name_#{n}" }
    start_date        { Faker::Date.backward(14) }
    end_date          { Faker::Date.backward(14) }
    sequence :make    { |n| "make_#{n}" }
    sequence :model   { |n| "model_#{n}" }
    created_at        { Faker::Date.backward(14) }
    updated_at        { Faker::Date.backward(14) }
    association         :city, factory: :city
    association         :country, factory: :country
    photo_ids         ""
    album_type        "standard"
    tags              ["kaj", "peter"]
    like              { Faker::Boolean.boolean }
  end
end
