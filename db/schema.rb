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

ActiveRecord::Schema.define(version: 20160624160036) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "apiaries", force: :cascade do |t|
    t.string   "name",           null: false
    t.string   "postal_code"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "city"
    t.string   "region"
    t.string   "street_address"
    t.string   "country"
    t.integer  "hives_count"
  end

  create_table "beekeepers", force: :cascade do |t|
    t.integer  "apiary_id",  null: false
    t.integer  "user_id",    null: false
    t.string   "role",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "beekeepers", ["apiary_id"], name: "index_beekeepers_on_apiary_id", using: :btree
  add_index "beekeepers", ["user_id", "apiary_id"], name: "index_beekeepers_on_user_id_and_apiary_id", using: :btree

  create_table "contact_requests", force: :cascade do |t|
    t.string   "name",          null: false
    t.string   "email_address", null: false
    t.string   "subject",       null: false
    t.string   "message",       null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "diseases", force: :cascade do |t|
    t.integer  "inspection_id", null: false
    t.string   "disease_type"
    t.string   "treatment"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "notes"
  end

  add_index "diseases", ["inspection_id"], name: "index_diseases_on_inspection_id", using: :btree

  create_table "harvest_edits", force: :cascade do |t|
    t.integer  "harvest_id",   null: false
    t.integer  "beekeeper_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "harvest_edits", ["beekeeper_id"], name: "index_harvest_edits_on_beekeeper_id", using: :btree
  add_index "harvest_edits", ["harvest_id"], name: "index_harvest_edits_on_harvest_id", using: :btree

  create_table "harvests", force: :cascade do |t|
    t.integer  "honey_weight"
    t.integer  "wax_weight"
    t.datetime "harvested_at"
    t.string   "weight_units"
    t.string   "notes"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "hive_id",            null: false
    t.string   "honey_weight_units"
    t.string   "wax_weight_units"
  end

  add_index "harvests", ["hive_id"], name: "index_harvests_on_hive_id", using: :btree

  create_table "hives", force: :cascade do |t|
    t.integer   "apiary_id",                                                                                       null: false
    t.string    "name",                                                                                            null: false
    t.string    "breed"
    t.string    "hive_type"
    t.boolean   "exact_location_sharing",                                                          default: false, null: false
    t.boolean   "data_sharing",                                                                    default: false, null: false
    t.datetime  "created_at",                                                                                      null: false
    t.datetime  "updated_at",                                                                                      null: false
    t.string    "orientation"
    t.string    "comments"
    t.string    "source"
    t.integer   "inspections_count"
    t.integer   "harvests_count"
    t.geography "coordinates",            limit: {:srid=>4326, :type=>"point", :geographic=>true}
  end

  add_index "hives", ["apiary_id"], name: "index_hives_on_apiary_id", using: :btree
  add_index "hives", ["coordinates"], name: "index_hives_on_coordinates", using: :gist

  create_table "inspection_edits", force: :cascade do |t|
    t.integer  "inspection_id", null: false
    t.integer  "beekeeper_id",  null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "inspection_edits", ["beekeeper_id"], name: "index_inspection_edits_on_beekeeper_id", using: :btree
  add_index "inspection_edits", ["inspection_id"], name: "index_inspection_edits_on_inspection_id", using: :btree

  create_table "inspections", force: :cascade do |t|
    t.decimal  "temperature",               precision: 10
    t.string   "weather_conditions"
    t.string   "weather_notes"
    t.string   "notes"
    t.boolean  "ventilated"
    t.string   "entrance_reducer"
    t.boolean  "queen_excluder"
    t.string   "hive_orientation"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.datetime "inspected_at",                             null: false
    t.integer  "hive_id",                                  null: false
    t.integer  "health"
    t.string   "brood_pattern"
    t.boolean  "eggs_sighted"
    t.boolean  "queen_sighted"
    t.boolean  "queen_cells_sighted"
    t.boolean  "swarm_cells_capped"
    t.boolean  "honey_sighted"
    t.boolean  "pollen_sighted"
    t.boolean  "swarm_cells_sighted"
    t.boolean  "supersedure_cells_sighted"
    t.string   "hive_temperament"
    t.string   "temperature_units"
  end

  add_index "inspections", ["hive_id"], name: "index_inspections_on_hive_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                           null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "authentication_token"
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "photo_url"
    t.string   "timezone"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
  end

  add_index "users", ["activation_token"], name: "index_users_on_activation_token", using: :btree
  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

end
