class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.integer :profile_id
      t.integer :linked_id
      t.string :linked_type
      t.text :message
      t.integer :site_id
      t.timestamps
    end
  end

  def self.down
    drop_table :histories
  end
end
