class CreateSiteMenuItems < ActiveRecord::Migration
  def self.up
    create_table :site_menu_items do |t|
      t.string :name, :redirect_url
      t.integer :site_menu_id, :site_route_id, :site_id, :sub_site_menu_id
      t.integer :position, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :site_menu_items
  end
end
