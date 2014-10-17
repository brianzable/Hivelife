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

ActiveRecord::Schema.define(version: 20141017143926) do

  create_table "apiaries", force: true do |t|
    t.string   "name"
    t.string   "zip_code"
    t.string   "photo_url",      default: "defaults/beehive_placeholder.png", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.string   "state"
    t.string   "street_address"
  end

  create_table "beekeepers", force: true do |t|
    t.integer  "apiary_id"
    t.integer  "user_id"
    t.string   "permission"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brood_boxes", force: true do |t|
    t.integer  "inspection_id"
    t.string   "pattern"
    t.boolean  "eggs_sighted"
    t.boolean  "queen_sighted"
    t.boolean  "queen_cells_sighted"
    t.boolean  "swarm_cells_capped"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "honey_sighted"
    t.boolean  "pollen_sighted"
    t.boolean  "swarm_cells_sighted"
    t.boolean  "supersedure_cells_sighted"
  end

  create_table "diseases", force: true do |t|
    t.integer  "inspection_id"
    t.string   "disease_type"
    t.string   "treatment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "harvests", force: true do |t|
    t.integer  "honey_weight"
    t.integer  "wax_weight"
    t.datetime "harvested_at"
    t.string   "weight_units"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hive_id"
  end

  create_table "hives", force: true do |t|
    t.integer  "apiary_id"
    t.string   "name",                                            default: "",                                 null: false
    t.string   "breed"
    t.string   "hive_type"
    t.string   "photo_url",                                       default: "defaults/beehive_placeholder.png", null: false
    t.string   "flight_pattern"
    t.boolean  "fine_location_sharing",                           default: false,                              null: false
    t.boolean  "public",                                          default: false,                              null: false
    t.boolean  "ventilated"
    t.boolean  "queen_excluder"
    t.boolean  "entrance_reducer"
    t.string   "entrance_reducer_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",              precision: 18, scale: 15
    t.decimal  "longitude",             precision: 18, scale: 15
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "orientation"
  end

  create_table "honey_supers", force: true do |t|
    t.integer  "inspection_id"
    t.decimal  "full",              precision: 10, scale: 0
    t.decimal  "capped",            precision: 10, scale: 0
    t.boolean  "ready_for_harvest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inspections", force: true do |t|
    t.decimal  "temperature",           precision: 10, scale: 0
    t.string   "weather_conditions"
    t.string   "weather_notes"
    t.string   "notes"
    t.boolean  "ventilated"
    t.boolean  "entrance_reducer"
    t.string   "entrance_reducer_size"
    t.boolean  "queen_excluder"
    t.string   "hive_orientation"
    t.string   "flight_pattern"
    t.string   "health"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "inspected_at"
    t.integer  "hive_id"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",                          null: false
    t.string   "last_name",                           null: false
    t.string   "time_zone"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
