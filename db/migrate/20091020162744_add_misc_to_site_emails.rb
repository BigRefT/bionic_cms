class AddMiscToSiteEmails < ActiveRecord::Migration
  def self.up
    add_column :site_emails, :misc_data, :string
  end

  def self.down
    remove_column :site_emails, :misc_data
  end
end
