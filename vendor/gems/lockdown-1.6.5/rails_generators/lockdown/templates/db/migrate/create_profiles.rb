class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :updated_by
      t.boolean :is_disabled

      t.timestamps
    end

		# The System profile is used as the updated_by reference when records 
    # are created programatically and the responsible user cannot be determined 
    # or is simply not available.
		# TODO: Change email address
		Profile.create(:first_name => "System",
										:last_name => "User",
										:email => "system@a.com")

  end

  def self.down
    drop_table :profiles
  end
end
