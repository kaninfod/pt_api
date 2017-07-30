

FactoryGirl.define do
  factory :photo do
    # sequence :id          { |n| n }
    date_taken            { Time.now - rand(10..25).weeks }
    # sequence :filename    { |n| "this/is/the/filename/#{n}" }
    # path                  ""
    created_at            { Time.now - rand(25..30).weeks }
    updated_at            { Time.now - rand(25..30).weeks }
    # file_thumb_path       ""
    file_extension        "jpg"
    file_size             { rand(1..9)*1000 }
    association           :location, factory: :location
    sequence :make        { |n| "make_#{n}" }
    sequence :model       { |n| "model_#{n}" }
    # original_width        { Faker::Number.number(4) }
    # original_height       { Faker::Number.number(4) }
    # longitude             { Faker::Number.between(1, 180) }
    # latitude              { Faker::Number.between(1, 180) }
    # status                { Faker::Number.number(1) }
    # phash                 { Faker::Number.number(6) }
    sequence :org_id        { |n| n }
    sequence :lg_id         { |n| n }
    sequence :md_id         { |n| n }
    sequence :tm_id         { |n| n }
  end
end
