class CreateSitePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :name, :title, :meta_keywords, :breadcrumb, :class_name
      t.text :meta_description
      t.integer :parent_id, :site_id, :site_layout_id
      t.boolean :published, :default => false
      t.boolean :ssl_required, :default => false
      t.boolean :allow_public_access, :default => false
      t.boolean :allow_registered_users, :default => false
      t.datetime :published_at
      t.timestamps
    end

    create_table :pages_user_groups, :id => false do |t|
      t.integer :page_id
      t.integer :user_group_id
    end
  end

  def self.down
    drop_table :pages_user_groups
    drop_table :pages
  end
end
