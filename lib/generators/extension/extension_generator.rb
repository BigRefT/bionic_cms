begin
  require 'git'
rescue LoadError
end

class ExtensionGenerator < Rails::Generator::NamedBase
  default_options :with_rspec => false
  
  attr_reader :extension_path, :extension_file_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    @extension_file_name = "#{file_name}_extension"
    @extension_path = "vendor/extensions/#{file_name}"
  end
  
  def manifest
    record do |m|
      m.directory "#{extension_path}/app/blocks"
      m.directory "#{extension_path}/app/controllers"
      m.directory "#{extension_path}/app/drops"
      m.directory "#{extension_path}/app/filters"
      m.directory "#{extension_path}/app/helpers"
      m.directory "#{extension_path}/app/models"
      m.directory "#{extension_path}/app/views"
      m.directory "#{extension_path}/db/migrate"
      m.directory "#{extension_path}/config"
      m.directory "#{extension_path}/lib/tasks"
      
      m.template 'README',              "#{extension_path}/README"
      m.template 'extension.rb',        "#{extension_path}/#{extension_file_name}.rb"
      m.template 'tasks.rake',          "#{extension_path}/lib/tasks/#{extension_file_name}_tasks.rake"
      m.template 'routes.rb',           "#{extension_path}/config/routes.rb"

      if options[:with_rspec]
        #
      else
        m.directory "#{extension_path}/test/fixtures"
        m.directory "#{extension_path}/test/functional"
        m.directory "#{extension_path}/test/unit"
        m.directory "#{extension_path}/test/unit/helpers"

        m.template 'Rakefile',            "#{extension_path}/Rakefile"
        m.template 'test_helper.rb',      "#{extension_path}/test/test_helper.rb"
        m.template 'functional_test.rb',  "#{extension_path}/test/functional/#{extension_file_name}_test.rb"
      end
    end
  end
  
  def class_name
    super.to_name.gsub(' ', '') + 'Extension'
  end
  
  def extension_name
    class_name.to_name('Extension')
  end
  
  def author_info
    @author_info ||= begin
      Git.global_config
    rescue NameError
      {}
    end
  end

  def homepage
    author_info['github.user'] ? "http://github.com/#{author_info['github.user']}/radiant-#{file_name}-extension" : "http://yourwebsite.com/#{file_name}"
  end

  def author_email
    author_info['user.email'] || 'your email'
  end

  def author_name
    author_info['user.name'] || 'Your Name'
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--with-rspec", 
           "Use RSpec for this extension instead of Test::Unit") { |v| options[:with_rspec] = v }
  end
end