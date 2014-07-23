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
    t.integer  "api_notify_logable_id"
    t.string   "api_notify_logable_type"
    t.string   "endpoint"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_notify_logs", ["api_notify_logable_id", "api_notify_logable_type"], name: "api_notify_logs_unique_index_on_api_notify_logable"

  create_table "api_notify_tasks", force: true do |t|
    t.text     "fields_updated"
    t.text     "identificators"
    t.integer  "api_notifiable_id"
    t.string   "api_notifiable_type"
    t.string   "endpoint"
    t.string   "method"
    t.text     "response"
    t.integer  "depending_id"
    t.boolean  "done",                           default: false
    t.string   "changes_hash",        limit: 32
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_notify_tasks", ["api_notifiable_id", "api_notifiable_type"], name: "api_notify_tasks_unique_index_on_api_notifiable"

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
