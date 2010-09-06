class AddContentEditorToSiteTables < ActiveRecord::Migration
  def self.up
    add_column :site_snippets, :content_type, :string, :default => 'plain text'
  end

  def self.down
    remove_column :site_snippets, :content_type
  end
end
