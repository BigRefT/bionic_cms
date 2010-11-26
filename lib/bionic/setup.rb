require "highline"
require "forwardable"

module Bionic
  class Setup
  
    class << self
      def bootstrap(config)
        setup = new
        setup.bootstrap(config)
        setup
      end
    end
    
    attr_accessor :config
    
    def bootstrap(config)
      @config = config
      @admin = create_admin_user(
        config[:admin_first_name],
        config[:admin_last_name],
        config[:admin_email],
        config[:admin_username],
        config[:admin_password]
      )
      
      load_database_template(config[:database_template])
      announce "Finished.\n\n"
    end
    
    def create_admin_user(first_name, last_name, email, username, password)
      unless first_name and last_name and email and username and password
        announce "Create the admin user (press enter for defaults)."
        first_name = prompt_for_admin_first_name unless first_name
        last_name = prompt_for_admin_last_name unless last_name
        email = prompt_for_admin_email unless email
        username = prompt_for_admin_username unless username
        password = prompt_for_admin_password unless password
      end

      # The System profile is used when records 
      # are created programatically and the responsible user cannot be determined 
      # or is simply not available.
      profile = Profile.new(
        :first_name => "System",
        :last_name => "User",
        :email => "system@a.com",
        :email_confirmation => "system@a.com"
      )
      profile.histories.build(:message => "Profile Created: Installation")
      profile.save

      profile = Profile.new(
        :first_name => first_name,
        :last_name => last_name,
        :email => email,
        :email_confirmation => email
      )
      profile.build_user(
        :password => password,
        :password_confirmation => password,
        :login => (username || email)
      )
      profile.histories.build(:message => "Profile Created: Installation")
      profile.save

      Lockdown::System.make_user_administrator(profile.user)
      profile.histories.create(:message => "Promoted to Administrator")
      profile.user
    end

    def load_database_template(filename)
      template = nil
      if filename
        name = find_template_in_path(filename)
        unless name
          announce "Invalid template name: #{filename}"
          filename = nil
        else
          template = load_template_file(name)
        end
      end
      unless filename
        templates = find_and_load_templates("#{BIONIC_ROOT}/db/templates/*.yml")
        templates.concat find_and_load_templates("#{RAILS_ROOT}/db/templates/*.yml") if BIONIC_ROOT != RAILS_ROOT
        choose do |menu|
          menu.header = "\nSelect a database template"
          menu.prompt = "[1-#{templates.size}]: "
          menu.select_by = :index
          templates.each { |t| menu.choice(t['name']) { template = t } }
        end
      end
      create_records(template)
    end

    private
      
      def prompt_for_admin_first_name
        first_name = ask('First Name (Administrator): ', String) do |q|
          q.validate = /^.{0,100}$/
          q.responses[:not_valid] = "Invalid first name. Must be at less than 100 characters long."
          q.whitespace = :strip
        end
        first_name = "Administrator" if first_name.blank?
        first_name
      end

      def prompt_for_admin_last_name
        last_name = ask('Last Name (User): ', String) do |q|
          q.validate = /^.{0,100}$/
          q.responses[:not_valid] = "Invalid last name. Must be at less than 100 characters long."
          q.whitespace = :strip
        end
        last_name = "User" if last_name.blank?
        last_name
      end

      def prompt_for_admin_email
        email = ask('Email (required - no default): ', String) do |q|
          q.validate = Bionic::EmailValidation
          q.responses[:not_valid] = "Invalid email (ex. user@domain.com)."
          q.whitespace = :strip
        end
        email = "administrator@domain.com" if email.blank?
        email
      end

      def prompt_for_admin_username
        username = ask('Username (admin): ', String) do |q|
          q.validate = /^(|.{3,40})$/
          q.responses[:not_valid] = "Invalid username. Must be at least 3 characters long."
          q.whitespace = :strip
        end
        username = "admin" if username.blank?
        username
      end
    
      def prompt_for_admin_password
        password = ask('Password (bionic): ', String) do |q|
          q.echo = false unless defined?(::JRuby) # JRuby doesn't support stty interaction
          q.validate = /^(|.{4,40})$/
          q.responses[:not_valid] = "Invalid password. Must be at least 4 characters long."
          q.whitespace = :strip
        end
        password = "bionic" if password.blank?
        password
      end
    
      def find_template_in_path(filename)
        [
          filename,
          "#{BIONIC_ROOT}/#{filename}",
          "#{BIONIC_ROOT}/db/templates/#{filename}",
          "#{RAILS_ROOT}/#{filename}",
          "#{RAILS_ROOT}/db/templates/#{filename}",
          "#{Dir.pwd}/#{filename}",
          "#{Dir.pwd}/db/templates/#{filename}",
        ].find { |name| File.file?(name) }
      end
    
      def find_and_load_templates(glob)
        templates = Dir[glob]
        templates.map! { |template| load_template_file(template) }
        templates.sort_by { |template| template['name'] }
      end
    
      def load_template_file(filename)
        YAML.load_file(filename)
      end
    
      def create_records(template)
        records = template['records']
        if records
          puts
          records.keys.each do |key|
            feedback "Creating #{key.to_s.underscore.humanize}" do
              model = model(key)
              model.reset_column_information
              record_pairs = order_by_id(records[key])
              step do
                record_pairs.each do |id, record|
                  model.new(record).save
                end
              end
            end
          end
        end
      end
    
      def model(model_name)
        model_name.to_s.singularize.constantize
      end
    
      def order_by_id(records)
        records.map { |name, record| [record['id'], record] }.sort { |a, b| a[0] <=> b[0] }
      end
    
      extend Forwardable
      def_delegators :terminal, :agree, :ask, :choose, :say
  
      def terminal
        @terminal ||= HighLine.new
      end
  
      def output
        terminal.instance_variable_get("@output")
      end
  
      def wrap(string)
        string = terminal.send(:wrap, string) unless terminal.wrap_at.nil?
        string
      end
  
      def print(string)
        output.print(wrap(string))
        output.flush
      end
  
      def puts(string = "\n")
        say string
      end
  
      def announce(string)
        puts "\n#{string}"
      end
            
      def feedback(process, &block)
        print "#{process}..."
        if yield
          puts "OK"
          true
        else
          puts "FAILED"
          false
        end
      rescue Exception => e
        puts "FAILED"
        raise e
      end
      
      def step
        yield if block_given?
        print '.'
      end
      
  end
end