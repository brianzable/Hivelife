class UpdateDatabaseFields < ActiveRecord::Migration
  def change
    change_table :apiaries do |t|
      t.string :country

      t.rename :state, :region
      t.rename :zip_code, :postal_code
      t.remove :photo_url
      t.change :name, :string, limit: nil, null: false
      t.change :postal_code, :string, limit: nil
      t.change :region, :string, limit: nil
      t.change :city, :string, limit: nil
      t.change :street_address, :string, limit: nil

      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    change_table :beekeepers do |t|
      t.rename :permission, :role
      t.change :role, :string, limit: nil, null: false
      t.change :apiary_id, :integer, null: false
      t.change :user_id, :integer, null: false

      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    change_table :diseases do |t|
      t.change :disease_type, :string, limit: nil
      t.change :treatment, :string, limit: nil
      t.change :inspection_id, :integer, null: false

      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    change_table :harvests do |t|
      t.change :weight_units, :string, limit: nil
      t.change :notes, :string, limit: nil
      t.change :hive_id, :integer, null: false

      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    change_table :hives do |t|
      t.change :name, :string, default: nil, limit: nil
      t.change :breed, :string, limit: nil
      t.change :hive_type, :string, limit: nil
      t.change :orientation, :string, limit: nil
      t.change :apiary_id, :integer, null: false

      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    change_table :inspections do |t|
      t.change :inspected_at, :datetime, null: false

      t.change :weather_conditions, :string, limit: nil
      t.change :weather_notes, :string, limit: nil
      t.change :notes, :string, limit: nil
      t.change :entrance_reducer, :string, limit: nil
      t.change :hive_orientation, :string, limit: nil
      t.change :hive_id, :integer, null: false

      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    change_table :users do |t|
      t.change :email, :string, default: nil, limit: nil, null: false
      t.change :crypted_password, :string, limit: nil
      t.change :salt, :string, limit: nil
      t.change :authentication_token, :string, limit: nil
      t.change :activation_state, :string, limit: nil
      t.change :activation_token, :string, limit: nil

      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    drop_table :brood_boxes
    drop_table :honey_supers

    add_index :beekeepers, [:user_id, :apiary_id]
    add_index :beekeepers, :apiary_id

    add_index :harvests, :hive_id
    add_index :inspections, :hive_id

    add_index :diseases, :inspection_id

    add_index :hives, :apiary_id
  end
end
