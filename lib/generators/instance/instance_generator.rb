require 'rbconfig'

class InstanceGenerator < Rails::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])
  
  DATABASES = %w( mysql postgresql sqlite3 sqlserver db2 )
  
  MYSQL_SOCKET_LOCATIONS = [
    "/tmp/mysql.sock",                        # default
    "/var/run/mysqld/mysqld.sock",            # debian/gentoo
    "/var/tmp/mysql.sock",                    # freebsd
    "/var/lib/mysql/mysql.sock",              # fedora
    "/opt/local/lib/mysql/mysql.sock",        # fedora
    "/opt/local/var/run/mysqld/mysqld.sock",  # mac + darwinports + mysql
    "/opt/local/var/run/mysql4/mysqld.sock",  # mac + darwinports + mysql4
    "/opt/local/var/run/mysql5/mysqld.sock"   # mac + darwinports + mysql5
  ]
    
  default_options :db => "mysql", :shebang => DEFAULT_SHEBANG, :freeze => false

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    usage("Databases supported for preconfiguration are: #{DATABASES.join(", ")}") if (options[:db] && !DATABASES.include?(options[:db]))
    @destination_root = args.shift
  end

  def manifest
    # The absolute location of the Bionic files
    root = File.expand_path(BIONIC_ROOT) 
    
    # Use /usr/bin/env if no special shebang was specified
    script_options     = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }
    
    record do |m|
      # Root directory
      m.directory ""
      
      # Standard files and directories
      base_dirs = %w(config config/environments config/initializers db lib lib/tasks lib/lockdown log script public vendor/plugins vendor/extensions)
      text_files = %w(CHANGELOG CONTRIBUTORS LICENSE INSTALL README lib/lockdown/init.rb)
      environments = Dir["#{root}/config/environments/*.rb"]
      scripts = Dir["#{root}/script/**/*"].reject { |f| f =~ /(destroy|generate|plugin)$/ }
      public_files = Dir["#{root}/public/**/*"]
      
      files = base_dirs + text_files + environments + scripts + public_files
      files.map! { |f| f = $1 if f =~ %r{^#{root}/(.+)$}; f }
      files.sort!
      
      files.each do |file|
        case
        when File.directory?("#{root}/#{file}")
          m.directory file
        when file =~ %r{^script/}
          m.file bionic_root(file), file, script_options
        else
          m.file bionic_root(file), file
        end
      end

      # script/generate
      m.file "instance_generate", "script/generate", script_options

      # database.yml
      m.template "databases/#{options[:db]}.yml", "config/database.yml", :assigns => {
        :app_name => app_name,
        :socket   => options[:db] == "mysql" ? mysql_socket_location : nil
      }

      # Instance Rakefile
      m.file "instance_rakefile", "Rakefile"

      # Instance Configurations
      m.file "instance_routes.rb", "config/routes.rb"
      m.template "instance_environment.rb", "config/environment.rb", :assigns => {
        :app_name => app_name
      }
      
      instance_initializers = [
        "session_store.rb",
        "backtrace_silencers.rb",
        "bionic_init.rb",
        "inflections.rb",
        "mime_types.rb",
        "new_rails_defaults.rb"
      ]
      instance_initializers.each do |instance_initializer|
        m.template "initializers/instance_#{instance_initializer}", "config/initializers/#{instance_initializer}", :assigns => {
          :app_name => app_name
        }
      end

      m.template "instance_boot.rb", "config/boot.rb"

      # Install Readme
      m.readme bionic_root("INSTALL")
    end
  end

  protected

    def banner
      "Usage: #{$0} /path/to/bionic/app [options]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("-r", "--ruby=path", String,
             "Path to the Ruby binary of your choice (otherwise scripts use env, dispatchers current path).",
             "Default: #{DEFAULT_SHEBANG}") { |v| options[:shebang] = v }
      opt.on("-d", "--database=name", String,
            "Preconfigure for selected database (options: #{DATABASES.join(", ")}).",
            "Default: mysql") { |v| options[:db] = v }
    end
    
    def mysql_socket_location
      RUBY_PLATFORM =~ /mswin32/ ? MYSQL_SOCKET_LOCATIONS.find { |f| File.exists?(f) } : nil
    end

  private

    def bionic_root(filename = '')
      File.join("..", "..", "..", "..", filename)
    end
    
    def app_name
      File.basename(File.expand_path(@destination_root))
    end
  
end
