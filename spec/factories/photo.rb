

FactoryGirl.define do
  factory :photo do
    sequence :id          { |n| n }
    date_taken            { Faker::Date.backward(14) }
    sequence :filename        { |n| "this/is/the/filename/#{n}" }
    path                  ""
    created_at            { Faker::Date.backward(14) }
    updated_at            { Faker::Date.backward(14) }
    file_thumb_path       ""
    file_extension        "jpg"
    file_size             { Faker::Number.number(4) }
    association             :location, factory: :location
    sequence :make        { |n| "make_#{n}" }
    sequence :model       { |n| "model_#{n}" }
    original_width        { Faker::Number.number(4) }
    original_height       { Faker::Number.number(4) }
    longitude             { Faker::Number.between(1, 180) }
    latitude              { Faker::Number.between(1, 180) }
    status                { Faker::Number.number(1) }
    phash                 { Faker::Number.number(6) }
    org_id                { Faker::Number.number(2) }
    lg_id                 { Faker::Number.number(2) }
    md_id                 { Faker::Number.number(2) }
    tm_id                 { Faker::Number.number(2) }
  end
end
