# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_03_051607) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "authorizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "authorizations_tags", id: false, force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "authorization_id", null: false
  end

  create_table "tag_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "decoder"
  end

  create_table "tags", force: :cascade do |t|
    t.string "epc", limit: 124
    t.string "pc", limit: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tag_type_id"
    t.datetime "last_seen_at"
    t.string "description"
  end

  create_table "tagscans", force: :cascade do |t|
    t.integer "antenna"
    t.integer "rssi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tag_id"
    t.index ["tag_id"], name: "index_tagscans_on_tag_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "tagscans", "tags"
end
