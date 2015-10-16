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

ActiveRecord::Schema.define(version: 20151010015548) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apiaries", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "zip_code",       limit: 255
    t.string   "photo_url",      limit: 255, default: "defaults/beehive_placeholder.png", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city",           limit: 255
    t.string   "state",          limit: 255
    t.string   "street_address", limit: 255
  end

  create_table "beekeepers", force: :cascade do |t|
    t.integer  "apiary_id"
    t.integer  "user_id"
    t.string   "permission", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brood_boxes", force: :cascade do |t|
    t.integer  "inspection_id"
    t.string   "pattern",                   limit: 255
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

  create_table "diseases", force: :cascade do |t|
    t.integer  "inspection_id"
    t.string   "disease_type",  limit: 255
    t.string   "treatment",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "harvests", force: :cascade do |t|
    t.integer  "honey_weight"
    t.integer  "wax_weight"
    t.datetime "harvested_at"
    t.string   "weight_units", limit: 255
    t.string   "notes",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hive_id"
  end

  create_table "hives", force: :cascade do |t|
    t.integer  "apiary_id"
    t.string   "name",                   limit: 255,                           default: "",    null: false
    t.string   "breed",                  limit: 255
    t.string   "hive_type",              limit: 255
    t.boolean  "exact_location_sharing",                                       default: false, null: false
    t.boolean  "data_sharing",                                                 default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",                           precision: 18, scale: 15
    t.decimal  "longitude",                          precision: 18, scale: 15
    t.string   "orientation",            limit: 255
    t.string   "comments"
    t.string   "source"
  end

  create_table "honey_supers", force: :cascade do |t|
    t.integer  "inspection_id"
    t.decimal  "full",              precision: 10
    t.decimal  "capped",            precision: 10
    t.boolean  "ready_for_harvest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inspections", force: :cascade do |t|
    t.decimal  "temperature",                       precision: 10
    t.string   "weather_conditions",    limit: 255
    t.string   "weather_notes",         limit: 255
    t.string   "notes",                 limit: 255
    t.boolean  "ventilated"
    t.boolean  "entrance_reducer"
    t.string   "entrance_reducer_size", limit: 255
    t.boolean  "queen_excluder"
    t.string   "hive_orientation",      limit: 255
    t.string   "flight_pattern",        limit: 255
    t.string   "health",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "inspected_at"
    t.integer  "hive_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                       limit: 255, null: false
    t.string   "crypted_password",            limit: 255
    t.string   "salt",                        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "authentication_token",        limit: 255
    t.string   "activation_state",            limit: 255
    t.string   "activation_token",            limit: 255
    t.datetime "activation_token_expires_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "photo_url"
  end

  add_index "users", ["activation_token"], name: "index_users_on_activation_token", using: :btree
  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
