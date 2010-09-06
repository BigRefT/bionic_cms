class CreateSiteSnippets < ActiveRecord::Migration
  def self.up
    create_table :site_snippets do |t|
      t.string :name
      t.text :content
      t.integer :site_id
      t.timestamps
    end
  end

  def self.down
    drop_table :site_snippets
  end
end
