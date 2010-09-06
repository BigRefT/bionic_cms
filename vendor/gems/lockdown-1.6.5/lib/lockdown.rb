$:.unshift File.dirname(__FILE__)

require 'logger'

require File.join("lockdown", "errors")
require File.join("lockdown", "helper")
require File.join("lockdown", "session")
require File.join("lockdown", "context")
require File.join("lockdown", "permission")
require File.join("lockdown", "database")
require File.join("lockdown", "rules")
require File.join("lockdown", "system")
require File.join("lockdown", "references")

module Lockdown
  extend Lockdown::References
  extend Lockdown::Helper

  VERSION = '1.6.5'

  class << self
    attr_accessor :logger

    # Returns the version string for the library.
    def version
      VERSION
    end

    def major_version
      version.split('.')[0].to_i
    end

    def minor_version
      version.split('.')[1].to_i
    end

    def patch_version
      version.split('.')[2].to_i
    end

    # Mixin Lockdown code to the appropriate framework and ORM
    def mixin
      if mixin_resource?("frameworks")
        unless mixin_resource?("orms")
          raise NotImplementedError, "ORM unknown to Lockdown!"
        end
      else
        Lockdown.logger.info "=> Note:: Lockdown cannot determine framework and therefore is not active.\n"
      end
    end # mixin

    def maybe_parse_init
      return if Lockdown::System.initialized?

      if File.exists?(Lockdown.init_file)
        Lockdown.logger.info "=> Requiring Lockdown rules engine: #{Lockdown.init_file} \n"
        load Lockdown.init_file
      else
        Lockdown.logger.info "=> Note:: Lockdown couldn't find init file: #{Lockdown.init_file}\n"
      end
    end

    private

    def mixin_resource?(str)
      wildcard_path = File.join( File.dirname(__FILE__), 'lockdown', str , '*.rb' ) 
      Dir[wildcard_path].each do |f|
        require f
        module_name = File.basename(f).split(".")[0]
        module_class = eval("Lockdown::#{str.capitalize}::#{Lockdown.camelize(module_name)}")
        if module_class.use_me?
          include module_class
          return true
        end
      end
      false
    end # mixin_resource?
  end # class block

  self.logger = Logger.new(STDOUT)

end # Lockdown

Lockdown.logger.info "=> Mixing in Lockdown version: #{Lockdown.version} \n"
Lockdown.mixin


