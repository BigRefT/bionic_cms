class AddContentTypeToSitePageParts < ActiveRecord::Migration
  def self.up
    add_column :site_page_parts, :content_type, :string, :default => 'plain text'
  end

  def self.down
    remove_column :site_page_parts, :content_type
  end
end
