

FactoryGirl.define do
  factory :user do
    sequence :id          { |n| n }
    name                  { Faker::Internet.user_name }
    provider              ""
    uid                   ""
    created_at            { Faker::Date.backward(14) }
    updated_at            { Faker::Date.backward(14) }
    avatar                { Faker::Internet.url('example.com') }
    email                 { Faker::Internet.email }
    encrypted_password    { Faker::Internet.password }
    confirmation_token    { Faker::Internet.password }
    remember_token        { Faker::Internet.password }
    password_digest       { Faker::Internet.password }
  end
end
