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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "bans", :force => true do |t|
    t.integer  "level"
    t.string   "reason"
    t.datetime "expires_at"
    t.string   "ip"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ips", :force => true do |t|
    t.string   "ip"
    t.datetime "last_post",   :default => '-0001-12-31 20:00:00'
    t.datetime "last_thread", :default => '-0001-12-31 20:00:00'
    t.boolean  "banned",      :default => false
    t.integer  "ban_id"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "ips", ["ip"], :name => "index_ips_on_ip", :unique => true

  create_table "pictures", :force => true do |t|
    t.string   "md5_hash"
    t.string   "name"
    t.integer  "size"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "pictures", ["md5_hash"], :name => "index_pictures_on_md5_hash", :unique => true

  create_table "posts", :force => true do |t|
    t.text     "message"
    t.string   "ip"
    t.string   "password"
    t.boolean  "opening"
    t.integer  "replies_count", :default => 0
    t.boolean  "sticky",        :default => false
    t.boolean  "closed",        :default => false
    t.string   "title"
    t.datetime "bump"
    t.integer  "thread_id"
    t.boolean  "sage",          :default => false
    t.string   "picture_name"
    t.string   "picture_type"
    t.integer  "picture_size"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "posts", ["ip"], :name => "index_posts_on_ip"
  add_index "posts", ["opening"], :name => "index_posts_on_opening"
  add_index "posts", ["thread_id"], :name => "index_posts_on_thread_id"

  create_table "settings", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
