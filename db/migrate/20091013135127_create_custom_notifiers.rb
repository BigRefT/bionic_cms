class CreateCustomNotifiers < ActiveRecord::Migration
  def self.up
    create_table :custom_notifiers do |t|
      t.string :name
      t.string :notifier_type
      t.integer :site_id
      t.timestamps
    end
  end

  def self.down
    drop_table :custom_notifiers
  end
end
