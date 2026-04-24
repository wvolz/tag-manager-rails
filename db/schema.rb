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

ActiveRecord::Schema[8.0].define(version: 2026_04_23_100005) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.integer "bearer_id", null: false
    t.string "bearer_type", null: false
    t.string "token_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "comment"
    t.index ["bearer_id", "bearer_type"], name: "index_api_keys_on_bearer_id_and_bearer_type"
    t.index ["token_digest"], name: "index_api_keys_on_token_digest", unique: true
  end

  create_table "authorizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "authorizations_tags", id: false, force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "authorization_id", null: false
  end

  create_table "authorizer_apps", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reader_antennas", force: :cascade do |t|
    t.integer "reader_id", null: false
    t.integer "antenna", null: false
    t.integer "authorization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_id"], name: "index_reader_antennas_on_authorization_id"
    t.index ["reader_id", "antenna"], name: "index_reader_antennas_on_reader_id_and_antenna", unique: true
    t.index ["reader_id"], name: "index_reader_antennas_on_reader_id"
  end

  create_table "readers", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "authorizer_app_id"
    t.string "mac_address"
    t.string "reader_name"
    t.string "hostname"
    t.string "source_ip"
    t.datetime "last_seen_at"
    t.index ["authorizer_app_id"], name: "index_readers_on_authorizer_app_id"
    t.index ["mac_address"], name: "index_readers_on_mac_address", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "tag_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "decoder"
  end

  create_table "tags", force: :cascade do |t|
    t.string "epc", limit: 124
    t.string "pc", limit: 4
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "tag_type_id"
    t.datetime "last_seen_at", precision: nil
    t.string "description"
    t.string "tid", limit: 124
    t.string "user_memory", limit: 124
  end

  create_table "tagscans", force: :cascade do |t|
    t.integer "antenna"
    t.integer "rssi"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "tag_id"
    t.datetime "received_at"
    t.string "event_id"
    t.boolean "image_protected", default: false, null: false
    t.integer "reader_id"
    t.index ["event_id"], name: "index_tagscans_on_event_id", unique: true
    t.index ["reader_id"], name: "index_tagscans_on_reader_id"
    t.index ["tag_id"], name: "index_tagscans_on_tag_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "admin", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "reader_antennas", "authorizations"
  add_foreign_key "reader_antennas", "readers"
  add_foreign_key "readers", "authorizer_apps"
  add_foreign_key "tagscans", "readers"
  add_foreign_key "tagscans", "tags"
end
