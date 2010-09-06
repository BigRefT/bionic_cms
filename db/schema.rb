# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100913150159) do

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "changes"
    t.integer  "version",        :default => 0
    t.datetime "created_at"
    t.integer  "site_id"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "custom_notifiers", :force => true do |t|
    t.string   "name"
    t.string   "notifier_type"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_notifiers", ["notifier_type"], :name => "index_custom_notifiers_on_notifier_type"
  add_index "custom_notifiers", ["site_id"], :name => "index_custom_notifiers_on_site_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "extension_meta", :force => true do |t|
    t.string  "name"
    t.integer "schema_version", :default => 0
    t.boolean "enabled",        :default => true
  end

  create_table "histories", :force => true do |t|
    t.integer  "profile_id"
    t.integer  "linked_id"
    t.string   "linked_type"
    t.text     "message"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "histories", ["linked_id", "linked_type"], :name => "index_histories_on_linked_id_and_linked_type"
  add_index "histories", ["profile_id"], :name => "index_histories_on_profile_id"
  add_index "histories", ["site_id"], :name => "index_histories_on_site_id"

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "meta_keywords"
    t.string   "breadcrumb"
    t.string   "class_name"
    t.text     "meta_description"
    t.integer  "parent_id"
    t.integer  "site_id"
    t.integer  "site_layout_id"
    t.boolean  "published",              :default => false
    t.boolean  "ssl_required",           :default => false
    t.boolean  "allow_public_access",    :default => false
    t.boolean  "allow_registered_users", :default => false
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["class_name", "id"], :name => "index_pages_on_class_name_and_id"
  add_index "pages", ["parent_id"], :name => "index_pages_on_parent_id"
  add_index "pages", ["site_id"], :name => "index_pages_on_site_id"
  add_index "pages", ["site_layout_id"], :name => "index_pages_on_site_layout_id"

  create_table "pages_user_groups", :id => false, :force => true do |t|
    t.integer "page_id"
    t.integer "user_group_id"
  end

  add_index "pages_user_groups", ["page_id", "user_group_id"], :name => "page_group_index"
  add_index "pages_user_groups", ["user_group_id", "page_id"], :name => "group_page_index"

  create_table "permissions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions_user_groups", :id => false, :force => true do |t|
    t.integer "permission_id"
    t.integer "user_group_id"
  end

  add_index "permissions_user_groups", ["permission_id", "user_group_id"], :name => "permission_group_index"
  add_index "permissions_user_groups", ["user_group_id", "permission_id"], :name => "group_permission_index"

  create_table "profiles", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "updated_by"
    t.boolean  "is_disabled"
    t.string   "remember_token"
    t.boolean  "delta",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "site_assets", :force => true do |t|
    t.string   "display_name"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.string   "asset_file_size"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_assets", ["asset_file_name"], :name => "index_site_assets_on_asset_file_name"
  add_index "site_assets", ["site_id"], :name => "index_site_assets_on_site_id"

  create_table "site_emails", :force => true do |t|
    t.string   "notifier_name"
    t.string   "subject"
    t.string   "from"
    t.string   "cc"
    t.string   "bcc"
    t.string   "reply_to"
    t.string   "content_type"
    t.integer  "site_snippet_id"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number_of_days_after_to_send", :default => 0
    t.boolean  "active",                       :default => false
    t.string   "misc_data"
  end

  add_index "site_emails", ["notifier_name"], :name => "index_site_emails_on_notifier_name"
  add_index "site_emails", ["site_id"], :name => "index_site_emails_on_site_id"
  add_index "site_emails", ["site_snippet_id"], :name => "index_site_emails_on_site_snippet_id"

  create_table "site_layouts", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type"
    t.integer  "live_version"
  end

  add_index "site_layouts", ["site_id"], :name => "index_site_layouts_on_site_id"

  create_table "site_menu_items", :force => true do |t|
    t.string   "name"
    t.string   "redirect_url"
    t.integer  "site_menu_id"
    t.integer  "site_route_id"
    t.integer  "site_id"
    t.integer  "sub_site_menu_id"
    t.integer  "position",         :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "live_version"
    t.boolean  "draft_delete",     :default => false
    t.boolean  "draft_new",        :default => false
  end

  add_index "site_menu_items", ["site_id"], :name => "index_site_menu_items_on_site_id"
  add_index "site_menu_items", ["site_menu_id"], :name => "index_site_menu_items_on_site_menu_id"
  add_index "site_menu_items", ["site_route_id"], :name => "index_site_menu_items_on_site_route_id"

  create_table "site_menus", :force => true do |t|
    t.string   "name"
    t.string   "handle"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "in_draft_mode", :default => false
  end

  add_index "site_menus", ["handle"], :name => "index_site_menus_on_handle"
  add_index "site_menus", ["site_id"], :name => "index_site_menus_on_site_id"

  create_table "site_page_parts", :force => true do |t|
    t.string   "name"
    t.string   "filter"
    t.text     "content"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type", :default => "plain text"
    t.integer  "live_version"
  end

  add_index "site_page_parts", ["page_id"], :name => "index_site_page_parts_on_page_id"

  create_table "site_routes", :force => true do |t|
    t.string   "url_handle"
    t.string   "redirect_url"
    t.string   "routeable_type"
    t.integer  "routeable_id"
    t.integer  "site_id"
    t.boolean  "main_route",                  :default => false
    t.boolean  "status_301",                  :default => false
    t.boolean  "exclude_from_store_location", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_routes", ["routeable_id", "routeable_type"], :name => "routeable_index"
  add_index "site_routes", ["site_id"], :name => "index_site_routes_on_site_id"

  create_table "site_snippets", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type", :default => "plain text"
    t.integer  "live_version"
  end

  add_index "site_snippets", ["name"], :name => "index_site_snippets_on_name"
  add_index "site_snippets", ["site_id"], :name => "index_site_snippets_on_site_id"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "domain"
    t.boolean  "no_ssl",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.integer  "site_id"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "site_id"
  end

  create_table "user_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
  end

  add_index "user_groups", ["site_id"], :name => "index_user_groups_on_site_id"

  create_table "user_groups_users", :id => false, :force => true do |t|
    t.integer "user_group_id"
    t.integer "user_id"
  end

  add_index "user_groups_users", ["user_group_id"], :name => "index_user_groups_users_on_user_group_id"
  add_index "user_groups_users", ["user_id"], :name => "index_user_groups_users_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "salt"
    t.integer  "profile_id"
    t.boolean  "disabled",         :default => false
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
    t.datetime "last_login_at"
  end

  add_index "users", ["profile_id"], :name => "index_users_on_profile_id"
  add_index "users", ["site_id"], :name => "index_users_on_site_id"

end
