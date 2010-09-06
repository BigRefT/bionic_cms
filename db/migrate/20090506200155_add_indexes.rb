class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :profile_id
    add_index :user_groups_users, :user_group_id
    add_index :user_groups_users, :user_id
  end

  def self.down
    remove_index :users, :profile_id
    remove_index :user_groups_users, :user_group_id
    remove_index :user_groups_users, :user_id
  end
end
