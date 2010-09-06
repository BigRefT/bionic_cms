class AddDraftColumns < ActiveRecord::Migration
  def self.up
    add_column :site_snippets,      :live_version, :integer
    add_column :site_layouts,       :live_version, :integer
    add_column :site_page_parts,    :live_version, :integer
  end

  def self.down
    remove_column :site_snippets,   :live_version
    remove_column :site_layouts,    :live_version
    remove_column :site_page_parts, :live_version
  end
end
