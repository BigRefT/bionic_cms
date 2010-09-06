class AddContentTypeToSiteLayouts < ActiveRecord::Migration
  def self.up
    add_column :site_layouts, :content_type, :string
  end

  def self.down
    remove_column :site_layouts, :content_type
  end
end
