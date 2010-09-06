class AddDraftToSiteMenus < ActiveRecord::Migration
  def self.up
    add_column :site_menus,       :in_draft_mode, :boolean, :default => false
    add_column :site_menu_items,  :live_version,  :integer
    add_column :site_menu_items,  :draft_delete,  :boolean, :default => false
    add_column :site_menu_items,  :draft_new,     :boolean, :default => false
  end

  def self.down
    remove_column :site_menus,       :in_draft_mode
    remove_column :site_menu_items,  :live_version
    remove_column :site_menu_items,  :draft_delete
    remove_column :site_menu_items,  :draft_new
  end
end
