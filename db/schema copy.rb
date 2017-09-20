# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170919082259) do

  create_table "albums", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.string "make"
    t.string "model"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country"
    t.string "city"
    t.string "album_type"
    t.string "tags", default: "--- []\n"
    t.boolean "like"
    t.boolean "has_comment"
    t.integer "size"
    t.string "cover_url"
  end

  create_table "albums_photos", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "album_id"
    t.bigint "photo_id"
    t.index ["album_id"], name: "index_albums_photos_on_album_id"
    t.index ["photo_id"], name: "index_albums_photos_on_photo_id"
  end

  create_table "catalogs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "path"
    t.boolean "default"
    t.text "watch_path"
    t.string "type"
    t.string "sync_from_albums"
    t.integer "sync_from_catalog"
    t.string "ext_store_data", limit: 1024
    t.boolean "import_mode"
    t.integer "user_id"
  end

  create_table "cities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
  end

  create_table "countries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
  end

  create_table "facets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "user_id"
    t.bigint "photo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.bigint "source_id"
    t.index ["photo_id"], name: "index_facets_on_photo_id"
    t.index ["source_id"], name: "index_facets_on_source_id"
    t.index ["type"], name: "index_facets_on_type"
    t.index ["user_id"], name: "fk_rails_a4bb3b7eb2"
  end

  create_table "instances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "path"
    t.integer "size"
    t.datetime "modified"
    t.integer "status"
    t.string "rev"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "facet_id"
    t.string "photo_url"
    t.string "photo_id"
    t.string "instance_type"
    t.index ["facet_id"], name: "index_instances_on_facet_id"
  end

  create_table "jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "job_type"
    t.string "job_error"
    t.string "arguments"
    t.datetime "completed_at"
    t.string "queue"
    t.integer "status"
    t.integer "jobable_id"
    t.string "jobable_type"
  end

  create_table "locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "status"
    t.decimal "latitude", precision: 16, scale: 10
    t.decimal "longitude", precision: 16, scale: 10
    t.string "location"
    t.string "state"
    t.string "address"
    t.string "road"
    t.string "suburb"
    t.string "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "map_image_id"
    t.bigint "country_id"
    t.bigint "city_id"
    t.index ["city_id"], name: "index_locations_on_city_id"
    t.index ["country_id"], name: "index_locations_on_country_id"
  end

  create_table "photofiles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.string "size"
    t.string "filetype"
  end

  create_table "photos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "date_taken"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_extension"
    t.integer "file_size"
    t.bigint "location_id"
    t.string "make"
    t.string "model"
    t.integer "original_height"
    t.integer "original_width"
    t.decimal "longitude", precision: 16, scale: 10
    t.decimal "latitude", precision: 16, scale: 10
    t.integer "status", default: 0
    t.string "phash"
    t.integer "org_id"
    t.integer "lg_id"
    t.integer "md_id"
    t.integer "tm_id"
    t.index ["date_taken"], name: "index_photos_on_date_taken"
    t.index ["location_id"], name: "index_photos_on_location_id"
    t.index ["phash"], name: "index_photos_on_phash"
    t.index ["status"], name: "index_photos_on_status"
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", collation: "utf8_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "avatar"
    t.string "email"
    t.string "token", limit: 128
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email"
    t.index ["token"], name: "index_users_on_token"
  end

  add_foreign_key "albums_photos", "albums"
  add_foreign_key "albums_photos", "photos"
  add_foreign_key "facets", "users"
  add_foreign_key "locations", "cities"
  add_foreign_key "locations", "countries"
  add_foreign_key "photos", "locations"
end
