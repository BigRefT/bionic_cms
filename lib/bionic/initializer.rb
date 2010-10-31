# modified from Radiant CMS => http://www.radiant.org
# Add necessary Rails path
$LOAD_PATH.unshift "#{BIONIC_ROOT}/vendor/rails/railties/lib"

require 'initializer'
require 'bionic/admin_interface'
require 'bionic/extension_loader'

module Bionic

  class Configuration < Rails::Configuration
    attr_accessor :extension_paths
    attr_writer :extensions
    attr_accessor :view_paths
    attr_accessor :extension_dependencies

    def initialize
      self.view_paths = []
      self.extension_paths = default_extension_paths
      self.extension_dependencies = []
      super
    end

    def default_extension_paths
      env = ENV["RAILS_ENV"] || RAILS_ENV
      paths = [RAILS_ROOT + '/vendor/extensions', BIONIC_ROOT + '/vendor/extensions'].uniq
      # There's no other way it will work, config/environments/test.rb loads too late
      # TODO: Should figure out how to include this extension path only for the tests that need it
      paths.unshift(BIONIC_ROOT + "/test/fixtures/extensions") if env == "test"
      paths
    end
    
    def extensions
      @extensions ||= all_available_extensions
    end
    
    def all_available_extensions
      # load vendorized extensions by inspecting load path(s)
      all = extension_paths.map do |path|
        Dir["#{path}/*"].select {|f| File.directory?(f) }
      end
      # load any gem that follows extension rules
      gems.inject(all) do |available,gem|
        available << gem.specification.full_gem_path if gem.specification and
          gem.specification.full_gem_path[/bionic-.*-extension-[\d\.]+$/]
        available
      end
      # strip version info to glean proper extension names
      all.flatten.map {|f| File.basename(f).gsub(/^bionic-|-extension-[\d\.]+$/, '') }.sort.map {|e| e.to_sym }
    end

    def admin_interface
      AdminInterface.instance
    end

    def gem(name, options = {})
      super
      extensions << $1.intern if gems.last.name =~ /^radiant-(.*)-extension$/
    end

    def check_extension_dependencies
      unloaded_extensions = []
      @extension_dependencies.each do |ext|
        extension = ext.camelcase + 'Extension'
        begin
          extension_class = extension.constantize
          unloaded_extensions << extension unless defined?(extension_class) && (extension_class.active?)
        rescue NameError
          unloaded_extensions << extension
        end
      end
      if unloaded_extensions.any?
        abort <<-end_error
Missing these required extensions:
#{unloaded_extensions}
end_error
      else
        return true
      end
    end

    private
    
    def gem_directories
      Dir["#{BIONIC_ROOT}/vendor/gems/*/lib"]
    end

    def framework_root_path
      BIONIC_ROOT + '/vendor/rails'
    end

    # Provide the load paths for the Bionic installation
    def default_load_paths
      # Add the app's controller directory
      paths = Dir["#{BIONIC_ROOT}/app/controllers/"]

      # Followed by the standard includes.
      paths.concat %w(
        app
        app/blocks
        app/controllers
        app/drops
        app/filters
        app/helpers
        app/metal
        app/models
        config
        lib
        vendor
      ).map { |dir| "#{BIONIC_ROOT}/#{dir}" }.select { |dir| File.directory?(dir) }

      paths.concat builtin_directories
      paths.concat gem_directories
    end

    def default_plugin_paths
      [
        "#{RAILS_ROOT}/vendor/plugins",
        "#{BIONIC_ROOT}/lib/core_extensions",
        "#{BIONIC_ROOT}/vendor/plugins"
      ]
    end

    def default_view_path
      File.join(BIONIC_ROOT, 'app', 'views')
    end

    def default_controller_paths
      [File.join(BIONIC_ROOT, 'app', 'controllers')]
    end

  end

  class Initializer < Rails::Initializer
    def self.run(command = :process, configuration = Configuration.new)
      Rails.configuration = configuration
      super
    end

    def set_autoload_paths
      extension_loader.add_extension_paths
      super
    end

    # override Rails initializer to insert extension metals
    def initialize_metal
      Rails::Rack::Metal.requested_metals = configuration.metals
      Rails::Rack::Metal.metal_paths = ["#{BIONIC_ROOT}/app/metal"] # reset Rails default to BIONIC_ROOT
      Rails::Rack::Metal.metal_paths += plugin_loader.engine_metal_paths
      Rails::Rack::Metal.metal_paths += extension_loader.metal_paths

      configuration.middleware.insert_before(
        :"ActionController::ParamsParser",
        Rails::Rack::Metal, :if => Rails::Rack::Metal.metals.any?)
    end

    def add_plugin_load_paths
      # checks for plugins within extensions:
      extension_loader.add_plugin_paths
      super
      ActiveSupport::Dependencies.load_once_paths -= extension_loader.extension_load_paths
    end

    def load_plugins
      # load and initialize bionic specific gems
      require "#{BIONIC_ROOT}/vendor/gems/acts-as-taggable-on-1.1.6/rails/init.rb"
      require "#{BIONIC_ROOT}/vendor/gems/acts_as_audited-1.1.0/rails/init.rb"
      require "#{BIONIC_ROOT}/vendor/gems/calendar_date_select-1.16.1/init.rb"
      require "#{BIONIC_ROOT}/vendor/gems/liquid-2.1.2/lib/liquid.rb"
      require "#{BIONIC_ROOT}/vendor/gems/paperclip-2.3.3/rails/init.rb"
      require "#{BIONIC_ROOT}/vendor/gems/will_paginate-2.3.14/lib/will_paginate.rb"
      require 'bionic/session'
      require 'encrypter'
      require 'lockdown'

      super

      extension_loader.load_extensions
      add_gem_load_paths
      load_gems
      check_gem_dependencies
    end

    def after_initialize
      super
      extension_loader.activate_extensions
      configuration.check_extension_dependencies
    end

    def initialize_default_admin_interface
      admin_interface.load_default_interface
    end
    
    def initialize_form_for_custom_actions
      Bionic::FormForOptions.instance.custom_actions << {
        :form_action => "login",
        :model => "user",
        :new_url => "/sessions",
        :edit_url => "/sessions"
      }

      Bionic::FormForOptions.instance.custom_actions << {
        :form_action => "contact_form",
        :model => "contact_form",
        :new_url => "/forms/contact",
        :edit_url => "/forms/contact"
      }
    end

    def initialize_framework_views
      view_paths = returning [] do |arr|
        # Add the singular view path if it's not in the list
        arr << configuration.view_path if !configuration.view_paths.include?(configuration.view_path)
        # Add the default view paths
        arr.concat configuration.view_paths
        # Add the extension view paths
        arr.concat extension_loader.view_paths
        # Reverse the list so extensions come first
        arr.reverse!
      end
      if configuration.frameworks.include?(:action_mailer) || defined?(ActionMailer::Base)
        ActionMailer::Base.template_root = view_paths
      end
      if configuration.frameworks.include?(:action_controller) || defined?(ActionController::Base)
        view_paths.each do |vp|
          unless ActionController::Base.view_paths.include?(vp)
            ActionController::Base.prepend_view_path vp
          end
        end
      end
    end

    def initialize_routing
      extension_loader.add_controller_paths
      super
    end

    def admin_interface
      configuration.admin_interface
    end

    def extension_loader
      ExtensionLoader.instance { |l| l.initializer = self }
    end
  end

end
