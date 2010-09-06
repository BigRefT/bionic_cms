# modified from Radiant CMS => http://www.radiant.org
require 'bionic/extension'
require 'method_observer'

module Bionic
  class ExtensionLoader

    class DependenciesObserver < MethodObserver
      attr_accessor :config

      def initialize(rails_config)
        @config = rails_config
      end

      def before_clear(*args)
        ExtensionLoader.deactivate_extensions
      end

      def after_clear(*args)
        ExtensionLoader.load_extensions
        ExtensionLoader.activate_extensions
      end
    end

    include Simpleton

    attr_accessor :initializer, :extensions

    def initialize
      self.extensions = []
    end

    def configuration
      initializer.configuration
    end

    def extension_load_paths
      load_extension_roots.map { |extension| load_paths_for(extension) }.flatten.select { |d| File.directory?(d) }
    end

    def plugin_paths
      load_extension_roots.map {|extension| "#{extension}/vendor/plugins" }.select {|d| File.directory?(d) }
    end

    def add_extension_paths
      extension_load_paths.reverse_each do |path|
        configuration.load_paths.unshift path
        $LOAD_PATH.unshift path
      end
    end

    def add_plugin_paths
      configuration.plugin_paths.concat plugin_paths
    end

    def controller_paths
      extensions.map { |extension| "#{extension.root}/app/controllers" }.select { |d| File.directory?(d) }
    end

    def add_controller_paths
      configuration.controller_paths.concat(controller_paths)
    end

    def view_paths
      extensions.map { |extension| "#{extension.root}/app/views" }.select { |d| File.directory?(d) }
    end

    def metal_paths
      load_extension_roots.map { |extension| "#{extension}/app/metal" }.select { |d| File.directory?(d) }.reverse
    end

    # Load the extensions
    def load_extensions
      @observer ||= DependenciesObserver.new(configuration).observe(::ActiveSupport::Dependencies)
      self.extensions = load_extension_roots.map do |root|
        begin
          extension_file = "#{File.basename(root).gsub(/^bionic-|-extension-[\d.]+$/,'')}_extension"
          extension = extension_file.camelize.constantize
          extension.unloadable
          extension.root = root
          extension
        rescue LoadError, NameError => e
          $stderr.puts "Could not load extension from file: #{extension_file}.\n#{e.inspect}"
          e.backtrace.each { |error| $stderr.puts error }
          nil
        end
      end.compact
    end

    def deactivate_extensions
      extensions.each &:deactivate
    end

    def activate_extensions
      initializer.initialize_default_admin_interface
      initializer.initialize_form_for_custom_actions
      # Reset the view paths after
      initializer.initialize_framework_views
      extensions.each &:activate
      # Make sure we have our subclasses loaded!
      SitePage.load_subclasses
      ThemePage.load_subclasses
    end
    alias :reactivate :activate_extensions

    private

      def load_paths_for(dir)
        if File.directory?(dir)
          %w(lib app/models app/controllers app/helpers app/filters app/blocks app/drops app/metal test/helpers).collect do |p|
            path = "#{dir}/#{p}"
            path if File.directory?(path)
          end.compact << dir
        else
          []
        end
      end

      def load_extension_roots
        @load_extension_roots ||= unless configuration.extensions.empty?
          select_extension_roots
        else
          []
        end
      end

      def select_extension_roots
        all_roots = all_extension_roots.dup
        roots = configuration.extensions.uniq.map do |ext_name|
          if :all === ext_name
            :all
          else
            ext_path = all_roots.detect do |maybe_path|
              File.basename(maybe_path).gsub(/^bionic-|-extension-[\d.]+$/, '') == ext_name.to_s
            end
            raise LoadError, "Cannot find the extension '#{ext_name}'!" if ext_path.nil?
            all_roots.delete(ext_path)
          end
        end
        if placeholder = roots.index(:all)
          # replace the :all symbol with any remaining paths
          roots[placeholder, 1] = all_roots
        end
        roots
      end

      def all_extension_roots
        @all_extension_roots ||= begin
          roots = configuration.extension_paths.map do |path|
            Dir["#{path}/*"].map {|f| File.expand_path(f) if File.directory?(f) }.compact.sort
          end
          configuration.gems.inject(roots) do |paths,gem|
            paths.tap { |p| p << gem.specification.full_gem_path if gem.specification and
                            gem.specification.full_gem_path[/bionic-.*-extension-[\d\.]+$/] }
          end
          roots.flatten
        end
      end
  end
end
