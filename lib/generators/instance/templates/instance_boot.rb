# Don't change this file!
# Configure your app in config/environment.rb and config/environments/*.rb

RAILS_ROOT = File.expand_path("#{File.dirname(__FILE__)}/..") unless defined?(RAILS_ROOT)

module Rails
  class << self
    def vendor_rails?
      File.exist?("#{RAILS_ROOT}/vendor/rails")
    end
  end
end

module Bionic
  class << self
    def boot!
      unless booted?
        preinitialize
        pick_boot.run
      end
    end

    def booted?
      defined? Bionic::Initializer
    end

    def pick_boot
      case
      when app?
        AppBoot.new
      when vendor?
        VendorBoot.new
      else
        GemBoot.new
      end
    end
 
    def vendor?
      File.exist?("#{RAILS_ROOT}/vendor/bionic")
    end
    
    def app?
      File.exist?("#{RAILS_ROOT}/lib/bionic.rb")
    end

    def preinitialize
      load(preinitializer_path) if File.exist?(preinitializer_path)
    end

    def loaded_via_gem?
      pick_boot.is_a? GemBoot
    end
 
    def preinitializer_path
      "#{RAILS_ROOT}/config/preinitializer.rb"
    end
  end

  class Boot
    def run
      load_initializer
    end
    
    def load_initializer
      begin
        require 'bionic'
        require 'bionic/initializer'
      rescue LoadError => e
        $stderr.puts %(Bionic could not be initialized. #{load_error_message})
        exit 1
      end
      Bionic::Initializer.run(:set_load_path)
    end
  end

  class VendorBoot < Boot
    def load_initializer
      $LOAD_PATH.unshift "#{RAILS_ROOT}/vendor/bionic/lib" 
      super
    end
        
    def load_error_message
      "Please verify that vendor/bionic contains a complete copy of the Bionic sources."
    end
  end

  class AppBoot < Boot
    def load_initializer
      $LOAD_PATH.unshift "#{RAILS_ROOT}/lib" 
      super
    end

    def load_error_message
      "Please verify that you have a complete copy of the Bionic sources."
    end
  end

  class GemBoot < Boot
    def load_initializer
      self.class.load_rubygems
      load_bionic_gem
      super
    end
      
    def load_error_message
     "Please reinstall the Bioinc gem with the command 'gem install bionic'."
    end
 
    def load_bionic_gem
      if version = self.class.gem_version
        gem 'bionic', version
      else
        gem 'bionic'
      end
    rescue Gem::LoadError => load_error
      $stderr.puts %(Missing the Bioinc #{version} gem. Please `gem install -v=#{version} bionic`, update your BIONIC_GEM_VERSION setting in config/environment.rb for the Bioinc version you do have installed, or comment out BIONIC_GEM_VERSION to use the latest version installed.)
      exit 1
    end
 
    class << self
      def rubygems_version
        Gem::RubyGemsVersion rescue nil
      end
 
      def gem_version
        if defined? BIONIC_GEM_VERSION
          BIONIC_GEM_VERSION
        elsif ENV.include?('BIONIC_GEM_VERSION')
          ENV['BIONIC_GEM_VERSION']
        else
          parse_gem_version(read_environment_rb)
        end
      end
 
      def load_rubygems
        require 'rubygems'
 
        min_version = '1.3.1'
        unless rubygems_version >= min_version
          $stderr.puts %(Bioinc requires RubyGems >= #{min_version} (you have #{rubygems_version}). Please `gem update --system` and try again.)
          exit 1
        end
 
      rescue LoadError
        $stderr.puts %(Bioinc requires RubyGems >= #{min_version}. Please install RubyGems and try again: http://rubygems.rubyforge.org)
        exit 1
      end
 
      def parse_gem_version(text)
        $1 if text =~ /^[^#]*BIONIC_GEM_VERSION\s*=\s*["']([!~<>=]*\s*[\d.]+)["']/
      end
 
      private
        def read_environment_rb
          File.read("#{RAILS_ROOT}/config/environment.rb")
        end
    end
  end
end

# All that for this:
Bionic.boot!