# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Bionic::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.

  # all of these are packaged in vendor/gems and are loaded via the bionic/initilizer
  # they are commented here for easy reference and for deployment use when upgrading gems (rake gems:unpack)
=begin
  config.gem 'acts-as-taggable-on', :version => '1.1.6'
  config.gem 'acts_as_audited', :version => '1.1.0', :lib => false
  config.gem 'calendar_date_select', :version => '1.16.1'
  config.gem 'highline', :version => '1.5.2'
  config.gem 'liquid', :version => '2.1.2'
  config.gem 'lockdown', :version => '1.6.5', :lib => false
  config.gem 'paperclip', :version => '2.3.3'
  config.gem 'rubyzip', :version => '0.9.4', :lib => 'zip/zipfilesystem'
  config.gem 'sentry', :version => '0.3.1'
  config.gem 'will_paginate', :version => '2.3.14'
=end

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  config.plugins = [ :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Only load the extensions named here, in the order given. By default all
  # extensions in vendor/extensions are loaded, in alphabetical order. :all
  # can be used as a placeholder for all extensions not explicitly named.
  config.extensions = [ :all ]

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'Eastern Time (US & Canada)'

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
end
