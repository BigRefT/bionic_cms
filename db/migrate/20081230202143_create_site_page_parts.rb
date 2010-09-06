class CreateSitePageParts < ActiveRecord::Migration
  def self.up
    create_table :site_page_parts do |t|
      t.string :name
      t.string :filter
      t.text :content
      t.integer :page_id
      t.timestamps
    end
  end

  def self.down
    drop_table :site_page_parts
  end
end
