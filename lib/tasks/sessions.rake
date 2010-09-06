namespace :bionic do
  desc "Delete row from the session table that have not been updated in ENV['DAYS_OLD'] days, default is 1."
  task :clean_session_table => :environment do
    days_ago = ENV['DAYS_OLD'] || 1
    remove_if_older_than = Date.today - days_ago.to_i

    puts "Removing sessions that are older than #{remove_if_older_than} from the #{ENV['RAILS_ENV']} database" unless ENV['SILENT']
    ActiveRecord::SessionStore::Session.destroy_all(['updated_at <= ?', remove_if_older_than])
  end
end