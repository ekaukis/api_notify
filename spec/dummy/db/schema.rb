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

ActiveRecord::Schema.define(version: 20140602120014) do

  create_table "api_notify_logs", force: true do |t|
    t.integer  "item_id"
    t.string   "endpoint"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_notify_logs", ["item_id"], name: "index_api_notify_logs_on_item_id"

  create_table "api_notify_tasks", force: true do |t|
    t.text     "fields_updated"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.text     "synchronized_to"
    t.boolean  "synchronized"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dealers", force: true do |t|
    t.string   "title"
    t.boolean  "synchronized"
    t.integer  "other_system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vehicle_types", force: true do |t|
    t.string   "title"
    t.string   "category"
    t.integer  "vehicle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vehicle_types", ["vehicle_id"], name: "index_vehicle_types_on_vehicle_id"

  create_table "vehicles", force: true do |t|
    t.string   "no"
    t.string   "vin"
    t.string   "make"
    t.integer  "dealer_id"
    t.string   "other"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
