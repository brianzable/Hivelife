class CreateContactRequests < ActiveRecord::Migration
  def change
    create_table :contact_requests do |t|
      t.string :name, null: false
      t.string :email_address, null: false
      t.string :subject, null: false
      t.string :message, null: false

      t.timestamps null: false
    end
  end
end
