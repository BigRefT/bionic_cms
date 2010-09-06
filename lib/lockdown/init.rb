Lockdown::System.configure do

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Configuration Options
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Options with defaults:
  #
  # Set User model:
  #      # make sure you use the string "User", not the constant
        options[:user_model] = "User"
  #
  # Set UserGroup model:
  #      # make sure you use the string "UserGroup", not the constant
        options[:user_group_model] = "UserGroup"
  #
  # Set who_did_it method
  #   This method is used in setting the created_by/updated_by fields and
  #   should be accessible to the controller
        options[:who_did_it] = :current_user_id
  #
  # Set default_who_did_it
  #   When current_user_id returns nil, this is the value to use
        options[:default_who_did_it] = 1
  #
  #   Lockdown version < 0.9.0 set this to:
  #       options[:default_who_did_it] = Profile::System
  #
  #   Should probably be something like:
  #      options[:default_who_did_it] = User::SystemId
  #
  # Set timeout to 1 hour:
         options[:session_timeout] = (60 * 60)
  #
  # Call method when timeout occurs (method must be callable by controller):
  #       options[:session_timeout_method] = :clear_session_values
  #
  # Set system to logout if unauthorized access is attempted:
  #       options[:logout_on_access_violation] = false
  #
  # Set redirect to path on unauthorized access attempt:
         options[:access_denied_path] = "/login"
  #
  # Set redirect to path on successful login:
         options[:successful_login_path] = "/"
  #
  # Set separator on links call
  #       options[:links_separator] = "|"
  #
  # If deploying to a subdirectory, set that here. Defaults to nil
  #       options[:subdirectory] = "blog"
  #       *Notice: Do not add leading or trailing slashes,
  #                Lockdown will handle this
  #
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Define permissions
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #
  # set_permission(:product_management).
  #   with_controller(:products)
  #
  # :product_management is the name of the permission which is later
  # referenced by the set_user_group method
  #
  # .with_controller(:products) defaults to all action_methods available on that
  #  controller.  You can change this behaviour by chaining on except_methods or
  #  only_methods.  (see examples below)
  #
  #  ** To define a namespaced controller use two underscores:
  #     :admin__products
  #
  # if products is your standard RESTful resource you'll get:
  #   ["products/index , "products/show",
  #    "products/new", "products/edit",
  #    "products/create", "products/update",
  #    "products/destroy"]
  #
  # You can chain method calls to restrict the methods for one controller
  # or you can add multiple controllers to one permission.
  #      
  #   set_permission(:security_management).
  #     with_controller(:users).
  #     and_controller(:user_groups).
  #     and_controller(:permissions) 
  #
  # In addition to with_controller(:controller) there are:
  #
  #   set_permission(:some_nice_permission_name).
  #     with_controller(:some_controller_name).
  #       only_methods(:only_method_1, :only_method_2)
  #
  #   set_permission(:some_nice_permission_name).
  #     with_controller(:some_controller_name).
  #       except_methods(:except_method_1, :except_method_2)
  #
  #   set_permission(:some_nice_permission_name).
  #     with_controller(:some_controller_name).
  #       except_methods(:except_method_1, :except_method_2).
  #     and_controller(:another_controller_name).
  #     and_controller(:yet_another_controller_name)
  #
  # Define your permissions here:
  
  set_permission(:sessions_management).with_controller(:sessions)
  set_permission(:profiles_management).with_controller(:admin__profiles)
  set_permission(:user_groups_management).with_controller(:admin__user_groups)
  set_permission(:permissions_management).with_controller(:admin__permissions)
  set_permission(:sites_management).with_controller(:admin__sites)
  set_permission(:site_layouts_management).with_controller(:admin__site_layouts)
  set_permission(:site_pages_management).with_controller(:admin__site_pages)
  set_permission(:site_snippets_management).with_controller(:admin__site_snippets)
  set_permission(:site_routes_management).with_controller(:admin__site_routes)
  set_permission(:site_assets_management).with_controller(:admin__site_assets)
  set_permission(:site_menus_management).with_controller(:admin__site_menus)
  set_permission(:site_emails_management).with_controller(:admin__site_emails)
  set_permission(:site_maintenance).with_controller(:admin__sites).only_methods(:index, :edit, :update)
  set_permission(:admin_dashboard).with_controller(:admin__dashboard)

  set_permission(:customer).with_controller(:customer)

  set_permission(:home).with_controller(:home)
  # extension specific permissions

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Built-in user groups
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #  You can assign the above permission to one of the built-in user groups
  #  by using the following:
  # 
  #  To allow public access on the permissions :sessions and :home:
  #    set_public_access :sessions, :home
  #     
  #  Restrict :my_account access to only authenticated users:
  #    set_protected_access :my_account
  #
  # Define the built-in user groups here:
  set_public_access :sessions_management, :home
  set_protected_access :customer

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Define user groups
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #
  #  set_user_group(:catalog_management, :category_management, 
  #                                      :product_management) 
  #
  #  :catalog_management is the name of the user group
  #  :category_management and :product_management refer to permission names
  #
  # 
  # Define your user groups here:
  set_user_group(:site_administrators, :admin_dashboard,
                                        :profiles_management,
                                        :user_groups_management,
                                        :permissions_management,
                                        :site_maintenance,
                                        :site_layouts_management,
                                        :site_snippets_management,
                                        :site_pages_management,
                                        :site_routes_management,
                                        :site_assets_management,
                                        :site_menus_management,
                                        :site_emails_management)

end
