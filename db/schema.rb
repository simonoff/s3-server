# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150116081901) do

  create_table "acls", force: :cascade do |t|
    t.string  "name",       limit: 255, default: "You"
    t.string  "permission", limit: 255, default: "FULL_CONTROL"
    t.integer "bucket_id"
  end

  create_table "buckets", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "errors", force: :cascade do |t|
    t.string  "code",       limit: 255
    t.string  "message",    limit: 255
    t.string  "resource",   limit: 255
    t.integer "request_id",             default: 1
  end

  create_table "s3_objects", force: :cascade do |t|
    t.string   "uri",          limit: 255
    t.string   "key",          limit: 255
    t.integer  "size"
    t.string   "md5",          limit: 255
    t.string   "content_type", limit: 255
    t.string   "file",         limit: 255
    t.integer  "bucket_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", limit: 255, default: "S3-server"
  end

end
