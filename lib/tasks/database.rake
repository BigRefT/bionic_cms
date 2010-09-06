namespace :db do
  desc "Migrate schema to version 0 and back up again. WARNING: Destroys all data in tables!!"
  task :remigrate => :environment do
    require 'highline/import'
    if ENV['OVERWRITE'].to_s.downcase == 'true' or agree("This task will destroy any data in the database. Are you sure you want to \ncontinue? [yn] ")
      
      require 'bionic/extension_migrator'
      # Migrate downward
      Bionic::Extension.descendants.reverse.each {|ext| ext.migrator.migrate(0) }
      ActiveRecord::Migrator.migrate("#{BIONIC_ROOT}/db/migrate/", 0)
    
      # Migrate upward 
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:migrate:extensions"].invoke
      
      # Dump the schema
      Rake::Task["db:schema:dump"].invoke
    else
      say "Task cancelled."
      exit
    end
  end
  
  desc "Bootstrap your database for Bionic."
  task :bootstrap => :remigrate do
    require 'bionic/setup'
    Bionic::Setup.bootstrap(
      :admin_first_name   => ENV['ADMIN_FIRST_NAME'],
      :admin_last_name    => ENV['ADMIN_LAST_NAME'],
      :admin_email        => ENV['ADMIN_EMAIL'],
      :admin_username     => ENV['ADMIN_USERNAME'],
      :admin_password     => ENV['ADMIN_PASSWORD'],
      :database_template  => ENV['DATABASE_TEMPLATE']
    )
  end
end