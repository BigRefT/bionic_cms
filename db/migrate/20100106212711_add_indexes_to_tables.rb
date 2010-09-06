class AddIndexesToTables < ActiveRecord::Migration
  def self.up
    add_index :custom_notifiers, :site_id
    add_index :custom_notifiers, :notifier_type
    add_index :histories, :site_id
    add_index :histories, :profile_id
    add_index :histories, [:linked_id, :linked_type]
    add_index :pages, [:class_name, :id]
    add_index :pages, :parent_id
    add_index :pages, :site_id
    add_index :pages, :site_layout_id
    add_index :pages_user_groups, [:page_id, :user_group_id], :name => 'page_group_index'
    add_index :pages_user_groups, [:user_group_id, :page_id], :name => 'group_page_index'
    add_index :permissions_user_groups, [:user_group_id, :permission_id], :name => 'group_permission_index'
    add_index :permissions_user_groups, [:permission_id, :user_group_id], :name => 'permission_group_index'
    add_index :profiles, :site_id
    add_index :profiles, :email
    add_index :profiles, [:email, :site_id], :name => 'profiles_emails_site_ids'
    add_index :site_assets, :site_id
    add_index :site_assets, :asset_file_name
    add_index :site_emails, :site_id
    add_index :site_emails, :site_snippet_id
    add_index :site_emails, :notifier_name
    add_index :site_layouts, :site_id
    add_index :site_menus, :site_id
    add_index :site_menus, :handle
    add_index :site_menu_items, :site_menu_id
    add_index :site_menu_items, :site_route_id
    add_index :site_menu_items, :site_id
    add_index :site_page_parts, :page_id
    add_index :site_routes, :site_id
    add_index :site_routes, [:routeable_id, :routeable_type], :name => 'routeable_index'
    add_index :site_snippets, :site_id
    add_index :site_snippets, :name
    add_index :users, :site_id
    add_index :user_groups, :site_id
  end

  def self.down
    remove_index :custom_notifiers, :site_id
    remove_index :custom_notifiers, :notifier_type
    remove_index :histories, :site_id
    remove_index :histories, :profile_id
    remove_index :histories, [:linked_id, :linked_type]
    remove_index :pages, [:class_name, :id]
    remove_index :pages, :parent_id
    remove_index :pages, :site_id
    remove_index :pages, :site_layout_id
    remove_index :pages_user_groups, :name => 'page_group_index'
    remove_index :pages_user_groups, :name => 'group_page_index'
    remove_index :permissions_user_groups, :name => 'group_permission_index'
    remove_index :permissions_user_groups, :name => 'permission_group_index'
    remove_index :profiles, :site_id
    remove_index :profiles, :email
    remove_index :profiles, :name => 'profiles_emails_site_ids'
    remove_index :site_assets, :site_id
    remove_index :site_assets, :asset_file_name
    remove_index :site_emails, :site_id
    remove_index :site_emails, :site_snippet_id
    remove_index :site_emails, :notifier_name
    remove_index :site_layouts, :site_id
    remove_index :site_menus, :site_id
    remove_index :site_menus, :handle
    remove_index :site_menu_items, :site_menu_id
    remove_index :site_menu_items, :site_route_id
    remove_index :site_menu_items, :site_id
    remove_index :site_page_parts, :page_id
    remove_index :site_routes, :site_id
    remove_index :site_routes, :name => 'routeable_index'
    remove_index :site_snippets, :site_id
    remove_index :site_snippets, :name
    remove_index :users, :site_id
    remove_index :user_groups, :site_id
  end
end
