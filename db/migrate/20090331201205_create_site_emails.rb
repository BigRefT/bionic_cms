class CreateSiteEmails < ActiveRecord::Migration
  def self.up
    create_table :site_emails do |t|
      t.string :notifier_name
      t.string :subject
      t.string :from
      t.string :cc
      t.string :bcc
      t.string :reply_to
      t.string :content_type
      t.integer :site_snippet_id
      t.integer :site_id
      t.timestamps
    end
  end

  def self.down
    drop_table :site_emails
  end
end
