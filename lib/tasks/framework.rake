# Only define freeze and unfreeze tasks in instance mode
unless File.directory? "#{RAILS_ROOT}/app"
  namespace :bionic do
    namespace :freeze do
      desc "Lock this application to the current gems (by unpacking them into vendor/bionic)"
      task :gems do
        require 'rubygems'
        require 'rubygems/gem_runner'

        bionic = (version = ENV['VERSION']) ?
          Gem.cache.search('bionic', "= #{version}").first :
          Gem.cache.search('bionic').sort_by { |g| g.version }.last

        version ||= bionic.version

        unless bionic
          puts "No bionic gem #{version} is installed.  Do 'gem list bionic' to see what you have available."
          exit
        end

        puts "Freezing to the gems for Bionic #{bionic.version}"
        rm_rf "vendor/bionic"

        chdir("vendor") do
          Gem::GemRunner.new.run(["unpack", "bionic", "--version", "=#{version}"])
          FileUtils.mv(Dir.glob("bionic*").first, "bionic")
        end
      end

      desc "Lock to latest Edge Bionic or a specific revision with REVISION=X (ex: REVISION=245484e), a tag with TAG=Y (ex: TAG=0.6.6), or a branch with BRANCH=Z (ex: BRANCH=mental)"
      task :edge do
        $verbose = false
        unless system "git --version"
          $stderr.puts "ERROR: Must have git available in the PATH to lock this application to Edge Bionic"
          exit 1
        end

        bionic_git = "git://github.com/BigRefT/bionic_cms.git"

        if File.exist?("vendor/bionic/.git/HEAD")
          system "cd vendor/bionic; git checkout master; git pull origin master"
        else
          system "git clone #{bionic_git} vendor/bionic"
        end

        case
        when ENV['TAG']
          system "cd vendor/bionic; git checkout -b v#{ENV['TAG']} #{ENV['TAG']}"
        when ENV['BRANCH']
          system "cd vendor/bionic; git checkout --track -b #{ENV['BRANCH']} origin/#{ENV['BRANCH']}"
        when ENV['REVISION']
          system "cd vendor/bionic; git checkout -b REV_#{ENV['REVISION']} #{ENV['REVISION']}"
        end

        system "cd vendor/bionic; git submodule init; git submodule update"
      end
    end

    desc "Unlock this application from freeze of gems or edge and return to a fluid use of system gems"
    task :unfreeze do
      rm_rf "vendor/bionic"
    end

    desc "Update configs, scripts, sass, stylesheets and javascripts from Bionic."
    task :update do
      tasks = %w{scripts javascripts configs initializers images stylesheets }
      tasks = tasks & ENV['ONLY'].split(',') if ENV['ONLY']
      tasks = tasks - ENV['EXCEPT'].split(',') if ENV['EXCEPT']
      tasks.each do |task| 
        puts "* Updating #{task}"
        Rake::Task["bionic:update:#{task}"].invoke
      end
    end

    namespace :update do
      desc "Add new scripts to the instance script/ directory"
      task :scripts do
        local_base = "script"
        edge_base  = "#{File.dirname(__FILE__)}/../../script"

        local = Dir["#{local_base}/**/*"].reject { |path| File.directory?(path) }
        edge  = Dir["#{edge_base}/**/*"].reject { |path| File.directory?(path) }
        edge  = edge.reject { |f| f =~ /(generate|plugin|destroy)$/ }

        edge.each do |script|
          base_name = script[(edge_base.length+1)..-1]
          next if local.detect { |path| base_name == path[(local_base.length+1)..-1] }
          if !File.directory?("#{local_base}/#{File.dirname(base_name)}")
            mkdir_p "#{local_base}/#{File.dirname(base_name)}"
          end
          install script, "#{local_base}/#{base_name}", :mode => 0755
        end
        install "#{File.dirname(__FILE__)}/../generators/instance/templates/instance_generate", "#{local_base}/generate", :mode => 0755
      end

      desc "Update config/boot.rb from your current bionic install"
      task :configs do
        require 'erb'
        FileUtils.cp("#{File.dirname(__FILE__)}/../generators/instance/templates/instance_boot.rb", RAILS_ROOT + '/config/boot.rb')
        instances = {
          :env          => "#{RAILS_ROOT}/config/environment.rb",
          :development  => "#{RAILS_ROOT}/config/environments/development.rb",
          :test         => "#{RAILS_ROOT}/config/environments/test.rb",
          :production   => "#{RAILS_ROOT}/config/environments/production.rb",
          :staging      => "#{RAILS_ROOT}/config/environments/staging.rb"
        }
        tmps = {
          :env          => "#{RAILS_ROOT}/config/environment.tmp",
          :development  => "#{RAILS_ROOT}/config/environments/development.tmp",
          :test         => "#{RAILS_ROOT}/config/environments/test.tmp",
          :production   => "#{RAILS_ROOT}/config/environments/production.tmp",
          :staging      => "#{RAILS_ROOT}/config/environments/staging.tmp"
        }
        gens = {
          :env          => "#{File.dirname(__FILE__)}/../generators/instance/templates/instance_environment.rb",
          :development  => "#{File.dirname(__FILE__)}/../../config/environments/development.rb",
          :test         => "#{File.dirname(__FILE__)}/../../config/environments/test.rb",
          :production   => "#{File.dirname(__FILE__)}/../../config/environments/production.rb",
          :staging      => "#{File.dirname(__FILE__)}/../../config/environments/staging.rb"
        }
        backups = {
          :env          => "#{RAILS_ROOT}/config/environment.bak",
          :development  => "#{RAILS_ROOT}/config/environments/development.bak",
          :test         => "#{RAILS_ROOT}/config/environments/test.bak",
          :production   => "#{RAILS_ROOT}/config/environments/production.bak",
          :staging      => "#{RAILS_ROOT}/config/environments/staging.bak"
        }
        @warning_start = "** WARNING **
The following files have been changed in Bionic. Your originals have 
been backed up with .bak extensions. Please copy your customizations to 
the new files:"
        [:env, :development, :test, :production, :staging].each do |env_type|
          File.open(tmps[env_type], 'w') do |f|
            app_name = File.basename(File.expand_path(RAILS_ROOT))
            f.write ERB.new(File.read(gens[env_type])).result(binding)
          end
          unless FileUtils.compare_file(instances[env_type], tmps[env_type])
            FileUtils.cp(instances[env_type], backups[env_type])
            FileUtils.cp(tmps[env_type], instances[env_type])
            @warnings ||= ""
            case env_type
            when :env
              @warnings << "
- config/environment.rb"
            else
              @warnings << "
- config/environments/#{env_type.to_s}.rb"
            end
          end
          FileUtils.rm(tmps[env_type])
        end
        if @warnings
          puts @warning_start + @warnings
        end
      end

      desc "Update your javascripts from your current bionic install"
      task :javascripts do
        FileUtils.mkdir_p("#{RAILS_ROOT}/public/javascripts/admin/")
        copy_javascripts = proc do |project_dir, scripts|
          scripts.reject!{|s| File.basename(s) == 'overrides.js'} if File.exists?(project_dir + 'overrides.js')
          FileUtils.cp(scripts, project_dir)
        end
        copy_javascripts[RAILS_ROOT + '/public/javascripts/', Dir["#{File.dirname(__FILE__)}/../../public/javascripts/*.js"]]
        copy_javascripts[RAILS_ROOT + '/public/javascripts/admin/', Dir["#{File.dirname(__FILE__)}/../../public/javascripts/admin/*.js"]]
        FileUtils.cp_r("#{File.dirname(__FILE__)}/../../public/javascripts/calendar_date_select", RAILS_ROOT + '/public/javascripts/')
        FileUtils.cp_r("#{File.dirname(__FILE__)}/../../public/javascripts/edit_area", RAILS_ROOT + '/public/javascripts/')
        FileUtils.cp_r("#{File.dirname(__FILE__)}/../../public/javascripts/fckeditor", RAILS_ROOT + '/public/javascripts/')
        FileUtils.cp_r("#{File.dirname(__FILE__)}/../../public/javascripts/livepipe", RAILS_ROOT + '/public/javascripts/')
      end

      desc "Update admin images from your current bionic install"
      task :images do
        FileUtils.mkdir_p("#{RAILS_ROOT}/public/images/admin/")
        FileUtils.mkdir_p("#{RAILS_ROOT}/public/images/calendar_date_select/")
        FileUtils.cp_r("#{File.dirname(__FILE__)}/../../public/images/admin", RAILS_ROOT + '/public/images/')
        FileUtils.cp_r("#{File.dirname(__FILE__)}/../../public/images/calendar_date_select", RAILS_ROOT + '/public/images/')
      end

      desc "Update admin stylesheets from your current bionic install"
      task :stylesheets do
        FileUtils.mkdir_p("#{RAILS_ROOT}/public/stylesheets/admin/")
        copy_stylesheets = proc do |project_dir, scripts|
          scripts.reject!{|s| File.basename(s) == 'overrides.css'} if File.exists?(project_dir + 'overrides.css')
          FileUtils.cp(scripts, project_dir)
        end
        copy_stylesheets[RAILS_ROOT + '/public/stylesheets/', Dir["#{File.dirname(__FILE__)}/../../public/stylesheets/*.css"]]
        copy_stylesheets[RAILS_ROOT + '/public/stylesheets/admin/', Dir["#{File.dirname(__FILE__)}/../../public/stylesheets/admin/*.css"]]
        FileUtils.cp_r("#{File.dirname(__FILE__)}/../../public/stylesheets/calendar_date_select", RAILS_ROOT + '/public/stylesheets/')
      end

      desc "Update initializers from your current bionic install"
      task :initializers do
        project_dir = RAILS_ROOT + '/config/initializers/'
        FileUtils.mkpath project_dir
        initializers = Dir["#{File.dirname(__FILE__)}/../../config/initializers/*.rb"]
        FileUtils.cp(initializers, project_dir)
      end
    end
  end
end