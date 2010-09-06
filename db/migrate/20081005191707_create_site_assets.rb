class CreateSiteAssets < ActiveRecord::Migration
  def self.up
    create_table :site_assets do |t|
      t.string :display_name
      t.string :asset_file_name
      t.string :asset_content_type
      t.string :asset_file_size
      t.integer :site_id
      t.timestamps
    end
  end

  def self.down
    drop_table :site_assets
  end
end
