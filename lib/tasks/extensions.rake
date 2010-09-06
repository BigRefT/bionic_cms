require 'rake/testtask'

namespace :db do
  namespace :migrate do
    desc "Run all Bionic extension migrations"
    task :extensions => :environment do
      require 'bionic/extension_migrator'
      Bionic::ExtensionMigrator.migrate_extensions
      Rake::Task['db:schema:dump'].invoke
    end
  end
  namespace :remigrate do
    desc "Migrate down and back up all Bionic extension migrations"
    task :extensions => :environment do
      require 'highline/import'
      if agree("This task will destroy any data stored by extensions in the database. Are you sure you want to \ncontinue? [yn] ")
        require 'bionic/extension_migrator'
        Bionic::Extension.descendants.each {|ext| ext.migrator.migrate(0) }
        Rake::Task['db:migrate:extensions'].invoke
        Rake::Task['db:schema:dump'].invoke
      end
    end
  end
end

namespace :test do
  desc "Runs tests on all available Bionic extensions, pass EXT=extension_name to test a single extension"
  task :extensions => "db:test:prepare" do
    extension_roots = Bionic::Extension.descendants.map(&:root)
    if ENV["EXT"]
      extension_roots = extension_roots.select {|x| /\/(\d+_)?#{ENV["EXT"]}$/ === x }
      if extension_roots.empty?
        puts "Sorry, that extension is not installed."
      end
    end
    extension_roots.each do |directory|
      if File.directory?(File.join(directory, 'test'))
        chdir directory do
          if RUBY_PLATFORM =~ /win32/
            system "rake.cmd test BIONIC_ENV_FILE=#{RAILS_ROOT}/config/environment"
          else
            system "rake test BIONIC_ENV_FILE=#{RAILS_ROOT}/config/environment"
          end
        end
      end
    end
  end
end

namespace :spec do
  desc "Runs specs on all available Bionic extensions, pass EXT=extension_name to test a single extension"
  task :extensions => "db:test:prepare" do
    extension_roots = Bionic::Extension.descendants.map(&:root)
    if ENV["EXT"]
      extension_roots = extension_roots.select {|x| /\/(\d+_)?#{ENV["EXT"]}$/ === x }
      if extension_roots.empty?
        puts "Sorry, that extension is not installed."
      end
    end
    extension_roots.each do |directory|
      if File.directory?(File.join(directory, 'spec'))
        chdir directory do
          if RUBY_PLATFORM =~ /win32/
            system "rake.cmd spec BIONIC_ENV_FILE=#{RAILS_ROOT}/config/environment"
          else
            system "rake spec BIONIC_ENV_FILE=#{RAILS_ROOT}/config/environment"
          end
        end
      end
    end
  end
end

namespace :bionic do
  # TODO: load previously copied tasks just once.
  # If update_all is run multiple times, previously copied tasks will be loaded twice,
  # once from the local copy (RAILS_ROOT/lib/tasks) and once from the gem source.
  task :extensions => :environment do
    Bionic::ExtensionLoader.instance.extensions.each do |extension|
      next if extension.root.starts_with? RAILS_ROOT
      Dir[File.join extension.root, %w(lib tasks *.rake)].sort.each { |task| load task }
    end
  end
  namespace :extensions do
    desc "Runs update asset task for all extensions"
    task :update_all => [:environment, 'bionic:extensions'] do
      extension_names = Bionic::ExtensionLoader.instance.extensions.map { |f| f.to_s.underscore.sub(/_extension$/, '') }
      extension_update_tasks = extension_names.map { |n| "bionic:extensions:#{n}:update" }.select { |t| Rake::Task.task_defined?(t) }
      extension_update_tasks.each {|t| Rake::Task[t].invoke }
    end
  end
end

# Load any custom rakefiles from extensions
[RAILS_ROOT, BIONIC_ROOT].uniq.each do |root|
  Dir[root + '/vendor/extensions/*/lib/tasks/*.rake'].sort.each { |ext| load ext }
end