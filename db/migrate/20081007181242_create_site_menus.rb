class CreateSiteMenus < ActiveRecord::Migration
  def self.up
    create_table :site_menus do |t|
      t.string :name, :handle
      t.integer :site_id
      t.timestamps
    end
  end

  def self.down
    drop_table :site_menus
  end
end
