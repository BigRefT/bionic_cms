require 'annotatable'
require 'simpleton'
require 'bionic'
require 'bionic/admin_interface'

# modified from Radiant CMS => http://www.radiant.org
module Bionic
  class Extension
    include Simpleton
    include Annotatable

    annotate :version, :description, :url, :root, :extension_name

    attr_writer :active

    def active?
      @active
    end
    
    def migrated?
      migrator.new(:up, migrations_path).pending_migrations.empty?
    end
    
    def enabled?
      active? and migrated?
    end
    
    # Conventional plugin-like routing
    def routed?
      File.exist?(routing_file)
    end

    def migrations_path
      File.join(self.root, 'db', 'migrate')
    end
    
    def routing_file
      File.join(self.root, 'config', 'routes.rb')
    end

    def migrator
      unless @migrator
        extension = self
        @migrator = Class.new(ExtensionMigrator){ self.extension = extension }
      end
      @migrator
    end

    def admin_interface
      AdminInterface.instance
    end

    def require_liquid_blocks
      # Auto-require /app/blocks
      Dir["#{root}/app/blocks/*.rb"].each do |block|
        require "#{File.basename(block).sub(/\.rb$/, '')}"
      end
    end
    
    def load_liquid_filters
      Dir["#{root}/app/filters/*.rb"].each do |filter|
        liquid_filters << "#{File.basename(filter).sub(/\.rb$/, '')}".camelize.constantize
      end
      register_liquid_filters
    end
    
    def register_liquid_filters
      liquid_filters.each do |liquid_filter|
        Liquid::Template.register_filter liquid_filter
      end
    end

    def liquid_filters
      @liquid_filters ||= []
    end

    def liquid_assigns
      @liquid_assigns ||= {}
    end

    # Determine if another extension is installed and up to date.
    #
    # if MyExtension.extension_enabled?(:third_party)
    #   ThirdPartyExtension.extend(MyExtension::IntegrationPoints)
    # end
    def extension_enabled?(extension)
      begin
        extension = (extension.to_s.camelcase + 'Extension').constantize
        extension.enabled?
      rescue NameError
        false
      end
    end

    class << self

      def activate_extension
        return if instance.active?
        instance.activate if instance.respond_to? :activate
        ActionController::Routing::Routes.add_configuration_file(instance.routing_file) if instance.routed?
        ActionController::Routing::Routes.reload
        instance.load_liquid_filters
        instance.require_liquid_blocks
        instance.active = true
      end
      alias :activate :activate_extension

      def deactivate_extension
        return unless instance.active?
        instance.active = false
        instance.deactivate if instance.respond_to? :deactivate
      end
      alias :deactivate :deactivate_extension

      def inherited(subclass)
        subclass.extension_name = subclass.name.to_name("Extension")
      end

      # Expose the configuration object for init hooks
      # class MyExtension < ActiveRecord::Base
      #   extension_config do |config|
      #     config.after_initialize do
      #       run_something
      #     end
      #   end
      # end
      def extension_config(&block)
        yield Rails.configuration
      end
    end
  end
end
