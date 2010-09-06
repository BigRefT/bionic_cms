class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :name
      t.string :domain
      t.boolean :no_ssl, :default => true
      t.timestamps
    end
    
    add_column :user_groups, :site_id, :integer
    add_column :users, :site_id, :integer
    add_column :profiles, :site_id, :integer
  end

  def self.down
    drop_table :sites
    remove_column :user_groups, :site_id
    remove_column :users, :site_id
    remove_column :profiles, :site_id
  end
end
