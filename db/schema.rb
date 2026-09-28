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

ActiveRecord::Schema[8.1].define(version: 2026_09_27_222438) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_josh3_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_josh3_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "token_digest", null: false
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token_digest"], name: "index_josh3_api_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_josh3_api_tokens_on_user_id"
  end

  create_table "channels", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_josh3_channels_on_slug", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.bigint "parent_id"
    t.text "body", null: false
    t.integer "score", default: 0, null: false
    t.decimal "hot_score", precision: 16, scale: 6, default: "0.0", null: false
    t.boolean "removed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_josh3_comments_on_created_at"
    t.index ["parent_id"], name: "index_josh3_comments_on_parent_id"
    t.index ["post_id"], name: "index_josh3_comments_on_post_id"
    t.index ["user_id"], name: "index_josh3_comments_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "channel_id", null: false
    t.string "title", null: false
    t.text "body"
    t.string "link_url"
    t.integer "score", default: 0, null: false
    t.decimal "hot_score", precision: 16, scale: 6, default: "0.0", null: false
    t.boolean "locked", default: false, null: false
    t.boolean "removed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id", "hot_score"], name: "index_josh3_posts_on_channel_id_and_hot_score"
    t.index ["channel_id"], name: "index_josh3_posts_on_channel_id"
    t.index ["created_at"], name: "index_josh3_posts_on_created_at"
    t.index ["user_id"], name: "index_josh3_posts_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "reportable_type", null: false
    t.bigint "reportable_id", null: false
    t.text "reason", null: false
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reportable_type", "reportable_id"], name: "index_josh3_reports_on_reportable"
    t.index ["user_id", "reportable_type", "reportable_id"], name: "index_reports_on_user_and_reportable", unique: true
    t.index ["user_id"], name: "index_josh3_reports_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "username", null: false
    t.string "password_digest", null: false
    t.text "bio"
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_josh3_users_on_email", unique: true
    t.index ["username"], name: "index_josh3_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "votable_type", null: false
    t.bigint "votable_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "votable_type", "votable_id"], name: "index_votes_on_user_and_votable", unique: true
    t.index ["user_id"], name: "index_josh3_votes_on_user_id"
    t.index ["votable_type", "votable_id"], name: "index_josh3_votes_on_votable"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "posts", "channels"
  add_foreign_key "posts", "users"
  add_foreign_key "reports", "users"
  add_foreign_key "votes", "users"
end
