class CreateSiteRoutes < ActiveRecord::Migration
  def self.up
    create_table :site_routes do |t|
      t.string :url_handle, :redirect_url, :routeable_type
      t.integer :routeable_id, :site_id
      t.boolean :main_route, :default => false
      t.boolean :status_301, :default => false
      t.boolean :exclude_from_store_location, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :site_routes
  end
end
