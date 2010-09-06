@override_next_migration_string = false

if Rails::VERSION::MAJOR >= 2 && Rails::VERSION::MINOR >= 1 
  if Rails::VERSION::TINY == 0
    @override_next_migration_string = true
  elsif ActiveRecord::Base.timestamped_migrations
    @override_next_migration_string = true
  end
end

if @override_next_migration_string
  class Rails::Generator::Commands::Base
    protected
    def next_migration_string(padding = 3)
      sleep(1)
      Time.now.utc.strftime("%Y%m%d%H%M%S") 
    end
  end
end

class LockdownGenerator < Rails::Generator::Base
  attr_accessor :file_name, :action_name, :namespace, :view_path, :controller_path

  def initialize(runtime_args, runtime_options = {})
    super
    if Rails::VERSION::MAJOR >= 2 && Rails::VERSION::MINOR >= 1
      @action_name = "action_name"
    else
      @action_name = "@action_name"
    end

    @namespace = options[:namespace] if options[:namespace]

    # so if the namespace option exists it sets the correct view path and controller path
    @view_path = "app/views"
    @controller_path = "app/controllers"
    @helper_path = "app/helpers"
    @lib_path = "lib/lockdown"

    @initializer = "config/environment.rb"

    if @namespace
      @view_path += "/#{@namespace}"
      @controller_path += "/#{@namespace}"
      @helper_path += "/#{@namespace}"
    end
  end

  def manifest
    record do |m|
      @m = m
      # Ensure appropriate folder(s) exists
      @m.directory @view_path
      @m.directory @controller_path
      @m.directory @helper_path
      @m.directory @lib_path

      unless options[:skip_rules]
        @m.file "lib/lockdown/README", "lib/lockdown/README"
        @m.file "lib/lockdown/init.rb", "lib/lockdown/init.rb"
      end

      add_management if options[:add_management]

      add_login if options[:add_login]

      add_models
      
      @m.file "config/initializers/lockit.rb", "config/initializers/lockit.rb"
    end #record do |m|
  end

  protected

  def add_management
    @m.directory "#{@view_path}/users"
    @m.directory "#{@view_path}/user_groups"
    @m.directory "#{@view_path}/permissions"

    write_controller("permissions")
    write_controller("users")
    write_controller("user_groups")

    copy_views("users")

    copy_views("user_groups")

    @m.template "app/views/permissions/index.html.erb",
      "#{@view_path}/permissions/index.html.erb"

    @m.template "app/views/permissions/show.html.erb",
      "#{@view_path}/permissions/show.html.erb"

    add_management_routes
    add_management_permissions
  end

  def add_login
    @m.directory "app/views/sessions"

    @m.template "app/controllers/sessions_controller.rb",
      "app/controllers/sessions_controller.rb"

    @m.template "app/views/sessions/new.html.erb",
      "app/views/sessions/new.html.erb"
    
    add_login_routes
    add_login_permissions
  end

  def add_models
    @m.directory 'app/models'

    write_model("user_group")
    write_model("permission") 

    if options[:add_lockdown_authentication]
      write_model("user") 
      write_model("profile") 
    end

    unless options[:skip_migrations]
      write_migration("create_user_groups")
      write_migration("create_permissions")

      if options[:add_lockdown_authentication]
        write_migration("create_profiles")
        write_migration("create_users")
        write_migration("create_admin_user")
      end
    end
  end

  def copy_views(vw)
    @m.template "app/views/#{vw}/index.html.erb", "#{@view_path}/#{vw}/index.html.erb"
    @m.template "app/views/#{vw}/show.html.erb", "#{@view_path}/#{vw}/show.html.erb"
    @m.template "app/views/#{vw}/edit.html.erb", "#{@view_path}/#{vw}/edit.html.erb"
    @m.template "app/views/#{vw}/new.html.erb", "#{@view_path}/#{vw}/new.html.erb"
  end

  def add_login_permissions
    add_permissions "set_permission(:sessions_management).with_controller(:sessions)"
    
    add_predefined_user_group "set_public_access :sessions_management"
  end

  def add_management_routes
    if @namespace.blank?
      permissions = %Q(\tmap.resources :permissions)
      users = %Q(\tmap.resources :users)
      user_groups = %Q(\tmap.resources :user_groups)
      routes = [permissions, user_groups, users].join("\n\n")
    else
      routes = %Q(\tmap.namespace :#{@namespace} do |#{@namespace}|\n\t\t#{@namespace}.resources :permissions\n\t\t#{@namespace}.resources :users\n\t\t#{@namespace}.resources :user_groups\n\tend)
    end

    write_routes_file(routes)
  end

  def add_management_permissions
    perms = []
    perms << "set_permission(:users_management).with_controller(:#{@namespace.blank? ? "users" : "#{@namespace}__users"})"
    perms << "set_permission(:user_groups_management).with_controller(:#{@namespace.blank? ? "user_groups" : "#{@namespace}__user_groups"})"
    perms << "set_permission(:permissions_management).with_controller(:#{@namespace.blank? ? "permissions" : "#{@namespace}__permissions"})"
    perms << "set_permission(:my_account).with_controller(:#{@namespace.blank? ? "users" : "#{@namespace}__users"}).only_methods(:edit, :update, :show)"

    add_permissions perms.join("\n  ")
    
    add_predefined_user_group "set_protected_access :my_account"
  end

  def add_permissions(str)
    sentinel = '# Define your permissions here:'
    write_init_file(sentinel, str)
  end

  def add_predefined_user_group(str)
    sentinel = '# Define the built-in user groups here:'
    write_init_file(sentinel, str)
  end

  def add_login_routes
    sessions = %Q(\tmap.resources :sessions)
    home     = %Q(\tmap.home '', :controller => 'sessions', :action => 'new')
    login    = %Q(\tmap.login '/login', :controller => 'sessions', :action => 'new')
    logout   = %Q(\tmap.logout '/logout', :controller => 'sessions', :action => 'destroy')
    routes   = [sessions, home, login, logout].join("\n\n")

    write_routes_file(routes)
  end

  def banner
<<-EOS
Installs the lockdown framework to managing users user_groups 
and viewing permissions. Also includes a login screen.

By default the entire set of stubs are installed.  

Please use the appropriate options to customize your install. 

USAGE: #{$0} #{spec.name} 
EOS
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'

    opt.on("--namespace=admin",
      "Install lockdown templates with a namespace, in this example 'admin'.") do |v|
        options[:namespace] = v 
      end

    opt.on("--add-lockdown-authentication",
      "Create user model + --add-login functionality.") do |v| 
        options[:add_lockdown_authentication] = v
      end

    opt.on("--add-management",
      "Create user, user_group, permission management controllers and views.") do |v|
        options[:add_management] = v
      end

    opt.on("--add-login",
      "Create session controller and views.") do |v| 
        options[:add_login] = v 
      end

    opt.on("--skip-rules",
      "Skip installation of lib/lockdown/init.rb lib/lockdown/session.rb") do |v| 
        options[:skip_rules] = v
      end

    opt.on("--skip-migrations",
      "Skip migrations installation") do |v| 
        options[:skip_migrations] = v
      end
  end

  def write_migration(str)
    @m.migration_template "db/migrate/#{str}.rb", "db/migrate", 
      :migration_file_name => str
  end

  def write_model(str)
    @m.file "app/models/#{str}.rb", "app/models/#{str}.rb"
  end

  def write_controller(str)
    @m.template "app/controllers/#{str}_controller.rb",
      "#{@controller_path}/#{str}_controller.rb"
    write_helper(str)
  end

  def write_helper(str)
    @m.template "app/helpers/#{str}_helper.rb",
      "#{@helper_path}/#{str}_helper.rb"
  end

  def write_routes_file(routes)
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
                
    @m.gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}\n #{routes}\n"
    end
  end

  def write_init_file(sentinel, str)
    @m.gsub_file 'lib/lockdown/init.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}\n  #{str}"
    end
  end
  
end
