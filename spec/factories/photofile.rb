
FactoryGirl.define do
  factory :photofile do
    # sequence :id      { |n| n }
    sequence :path    { |n| "/this/is/a/long/path/no/#{n}" }
    created_at        { Faker::Date.backward(14) }
    updated_at        { Faker::Date.backward(14) }
    filetype          "jpg"
    size              1234
    status            3
  end
end
