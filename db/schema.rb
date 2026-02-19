# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_19_031114) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.time "end_time"
    t.date "event_date", null: false
    t.bigint "image_id"
    t.string "location"
    t.time "start_time", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_events_on_category"
    t.index ["event_date", "category"], name: "index_events_on_event_date_and_category"
    t.index ["event_date"], name: "index_events_on_event_date"
    t.index ["image_id"], name: "index_events_on_image_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "alt_text"
    t.integer "bytes"
    t.string "cloudinary_public_id", null: false
    t.datetime "created_at", null: false
    t.string "format"
    t.integer "height"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.integer "width"
    t.index ["cloudinary_public_id"], name: "index_images_on_cloudinary_public_id", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.string "state"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["date_of_birth"], name: "index_members_on_date_of_birth"
    t.index ["last_name", "first_name"], name: "index_members_on_last_name_and_first_name"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "events", "images"
  add_foreign_key "sessions", "users"
end
