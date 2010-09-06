class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :crypted_password
      t.string :salt
      t.integer :profile_id
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
