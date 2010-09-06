class AddTriggersToSiteEmails < ActiveRecord::Migration
  def self.up
    add_column :site_emails, :number_of_days_after_to_send, :integer, :default => 0
    add_column :site_emails, :active, :boolean, :default => false
  end

  def self.down
    remove_column :site_emails, :number_of_days_after_to_send
    remove_column :site_emails, :active
  end
end
