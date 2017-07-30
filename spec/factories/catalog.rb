
FactoryGirl.define do
  factory :master_catalog do
    # sequence :id          { |n| n }
    sequence :name        { |n| "catalog_name_#{n}" }
    # name                  { Faker::Internet.user_name }
    created_at            { Faker::Date.backward(14) }
    updated_at            { Faker::Date.backward(14) }
    path                  "kaj"
    default               { Faker::Boolean.boolean }
    watch_path            [""]
    type                  "MasterCatalog"
    sync_from_albums      { [Faker::Number.number(2)] }
    sync_from_catalog     { Faker::Number.number(2) }
    ext_store_data        { }
    import_mode           { Faker::Boolean.boolean }
    association            :user, factory: :user
  end
end

FactoryGirl.define do
  factory :dropbox_catalog do
    # sequence :id          { |n| n }
    sequence :name        { |n| "catalog_name_#{n}" }
    # name                  { Faker::Internet.user_name }
    created_at            { Faker::Date.backward(14) }
    updated_at            { Faker::Date.backward(14) }
    path                  "kaj"
    default               { Faker::Boolean.boolean }
    watch_path            [""]
    type                  "DropboxCatalog"
    sync_from_albums      { [Faker::Number.number(2)] }
    sync_from_catalog     { Faker::Number.number(2) }
    ext_store_data        { }
    import_mode           { Faker::Boolean.boolean }
    association            :user, factory: :user
  end
end

FactoryGirl.define do
  factory :flickr_catalog do
    # sequence :id          { |n| n }
    sequence :name        { |n| "catalog_name_#{n}" }
    # name                  { Faker::Internet.user_name }
    created_at            { Faker::Date.backward(14) }
    updated_at            { Faker::Date.backward(14) }
    path                  "kaj"
    default               { Faker::Boolean.boolean }
    watch_path            [""]
    type                  "FlickrCatalog"
    sync_from_albums      { [Faker::Number.number(2)] }
    sync_from_catalog     { Faker::Number.number(2) }
    ext_store_data        { }
    import_mode           { Faker::Boolean.boolean }
    association            :user, factory: :user
  end
end
