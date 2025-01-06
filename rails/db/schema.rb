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

ActiveRecord::Schema[7.1].define(version: 2025_01_05_092011) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "gender_type", ["male", "female", "other", "unknown"]
  create_enum "video_type", ["karaoke", "cover", "talk", "game", "other", "uncategorized"]

  create_table "channels", id: { type: :string, comment: "Channel ID" }, force: :cascade do |t|
    t.string "title", null: false, comment: "Channel title"
    t.string "handle", null: false, comment: "Channel handle"
    t.text "description", null: false, comment: "Channel description"
    t.string "thumbnail", null: false, comment: "Channel thumbnail"
    t.bigint "vtuber_id", null: false, comment: "Vtuber ID"
    t.boolean "delete_flag", default: false, null: false, comment: "Delete flag"
    t.datetime "deleted_at", comment: "Deleted at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vtuber_id"], name: "index_channels_on_vtuber_id"
  end

  create_table "productions", force: :cascade do |t|
    t.string "name", null: false, comment: "Production name"
    t.boolean "delete_flag", default: false, null: false, comment: "Delete flag"
    t.datetime "deleted_at", comment: "Deleted at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "videos", id: { type: :string, comment: "Video ID" }, force: :cascade do |t|
    t.string "title", null: false, comment: "Video title"
    t.text "description", null: false, comment: "Video description"
    t.bigint "duration", null: false, comment: "Video duration"
    t.string "thumbnail", null: false, comment: "Video thumbnail"
    t.datetime "published_at", null: false, comment: "Video published at"
    t.bigint "view_count", null: false, comment: "Video view count"
    t.bigint "like_count", null: false, comment: "Video like count"
    t.bigint "comment_count", null: false, comment: "Video comment count"
    t.datetime "actual_start_time", comment: "Video actual start time"
    t.datetime "actual_end_time", comment: "Video actual end time"
    t.enum "type", default: "uncategorized", null: false, comment: "Type of video", enum_type: "video_type"
    t.string "channel_id", null: false, comment: "Channel ID"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vtubers", force: :cascade do |t|
    t.string "name", null: false, comment: "Name"
    t.enum "gender", default: "unknown", null: false, comment: "Gender", enum_type: "gender_type"
    t.datetime "birthday", comment: "Birthday"
    t.datetime "debut", comment: "Debut date"
    t.bigint "production_id", null: false, comment: "Production ID"
    t.boolean "delete_flag", default: false, null: false, comment: "Delete flag"
    t.datetime "deleted_at", comment: "Deleted at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["production_id"], name: "index_vtubers_on_production_id"
  end

  add_foreign_key "channels", "vtubers"
  add_foreign_key "videos", "channels"
  add_foreign_key "vtubers", "productions"
end
