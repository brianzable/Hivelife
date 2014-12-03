class CreateLandingPageSignups < ActiveRecord::Migration
  def change
    create_table :landing_page_signups do |t|
      t.string :email_address

      t.timestamps null: false
    end
  end
end
