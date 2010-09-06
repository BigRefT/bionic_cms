module Lockdown
  module Rules
    attr_accessor :options
    attr_accessor :permissions
    attr_accessor :user_groups

    attr_reader :protected_access 
    attr_reader :public_access

    attr_reader :permission_objects
 
    def set_defaults
      @permissions  = {}
      @user_groups  = {}
      @options      = {}

      @permission_objects = {}

      @public_access      = []
      @protected_access   = []

      @options = {
        :session_timeout => (60 * 60),
        :who_did_it => :current_user_id,
        :default_who_did_it => 1,
        :logout_on_access_violation => false,
        :access_denied_path => "/",
        :successful_login_path => "/",
        :subdirectory => nil,
        :skip_db_sync_in => ["test"],
        :link_separator => ' | ',
        :user_group_model => "UserGroup",
        :user_model => "User" 
      }
    end

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # =Rule defining methods.  e.g. Methods used in lib/lockdown/init.rb
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # Creates new permission object 
    #   Refer to the Permission object for the full functionality
    def set_permission(name)
      @permission_objects[name] = Lockdown::Permission.new(name)
    end

    # Defines public access by the permission symbols
    #
    # ==== Example
    #   set_public_access(:permission_one, :permission_two)
    #
    def set_public_access(*perms)
      perms.each do |perm_symbol|
        perm = find_permission_object(perm_symbol)
        if perm
          perm.set_as_public_access 
        else
          msg = "Permission not found: #{perm_symbol}"
          raise Lockdown::InvalidRuleAssignment, msg
        end
      end
    end

    # Defines protected access by the permission symbols
    #
    # ==== Example
    #   set_public_access(:permission_one, :permission_two)
    #
    def set_protected_access(*perms)
      perms.each do |perm_symbol|
        perm = find_permission_object(perm_symbol)
        if perm
          perm.set_as_protected_access 
        else
          msg = "Permission not found: #{perm_symbol}"
          raise Lockdown::InvalidRuleAssignment, msg
        end
      end
    end

    # Define a user groups by name and permission symbol(s)
    #
    # ==== Example
    #   set_user_group(:managment_group, :permission_one, :permission_two)
    #
    def set_user_group(name, *perms)
      user_groups[name] ||= []
      perms.each do |perm|
        if permission_assigned_automatically?(perm)
          raise Lockdown::InvalidPermissionAssignment, "Permission is assigned automatically.  Please remove it from #{name} user group"
        end
        user_groups[name].push(perm)
      end
    end
 
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # =Convenience methods for permissions and user groups
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    # Returns array of permission names as symbols
    def get_permissions
      permissions.keys
    end

    # Is the permission defined?
    def permission_exists?(permission_symbol)
      get_permissions.include?(permission_symbol)
    end

    alias_method :has_permission?, :permission_exists?
    
    # returns true if the permission is public
    def public_access?(perm_symbol)
      obj = find_permission_object(perm_symbol)
      obj.nil? ? false : obj.public_access? 
    end

    # returns true if the permission is public
    def protected_access?(perm_symbol)
      obj = find_permission_object(perm_symbol)
      obj.nil? ? false : obj.protected_access?
    end

    # These permissions are assigned by the system 
    def permission_assigned_automatically?(permmision_symbol)
      public_access?(permmision_symbol) || protected_access?(permmision_symbol)
    end

    # Returns array of user group names as symbols
    def get_user_groups
      user_groups.keys
    end

    # Is the user group defined?
    #   The :administrators user group always exists
    def user_group_exists?(user_group_symbol)
      return true if user_group_symbol == Lockdown.administrator_group_symbol
      get_user_groups.include?(user_group_symbol)
    end

    alias_method :has_user_group?, :user_group_exists?

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # =Convenience methods for permissions and user groups
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # Pass in a user object to be associated to the administrator user group 
    # The group will be created if it doesn't exist
    def make_user_administrator(usr)
      user_groups = usr.send(Lockdown.user_groups_hbtm_reference)
      user_groups << Lockdown.user_group_class.
        find_or_create_by_name(Lockdown.administrator_group_string)
    end


    # Returns array of controller/action values all logged in users can access.
    def standard_authorized_user_rights
      public_access + protected_access 
    end

    # Return array of controller/action values user can access.
    def access_rights_for_user(usr)
      return unless usr
      return :all if administrator?(usr)

      rights = standard_authorized_user_rights
        
      user_groups = usr.send(Lockdown.user_groups_hbtm_reference)
      user_groups.each do |grp|
        permissions_for_user_group(grp).each do |perm|
          rights += access_rights_for_permission(perm) 
        end
      end
      rights
    end

    # Return array of controller/action for a user group
    def access_rights_for_user_group(user_group_sym)
      res = []
      permissions_for_user_group(user_group_sym).each do |perm|
        res << access_rights_for_permission(perm)
      end
      res.flatten
    end

    # Return array of controller/action for a permission
    def access_rights_for_permission(perm)
      sym = Lockdown.get_symbol(perm)

      permissions[sym]
    rescue 
      raise SecurityError, "Permission requested is not defined: #{sym}"
    end


    # Test user for administrator rights
    def administrator?(usr)
      user_has_user_group?(usr, Lockdown.administrator_group_symbol)
    end

    # Pass in user object and symbol for name of user group
    def user_has_user_group?(usr, sym)
      user_groups = usr.send(Lockdown.user_groups_hbtm_reference)
      user_groups.any? do |ug|
        Lockdown.convert_reference_name(ug.name) == sym
      end
    end

    # Use this for the management screen to restrict user group list to the
    # user.  This will prevent a user from creating a user with more power than
    # him/her self.
    def user_groups_assignable_for_user(usr)
      return [] if usr.nil?
      ug_table = Lockdown.user_groups_hbtm_reference.to_s
      if administrator?(usr)
        Lockdown.user_group_class.find_by_sql <<-SQL
          select #{ug_table}.* from #{ug_table} order by #{ug_table}.name
        SQL
      else
        usr_table = Lockdown.users_hbtm_reference.to_s
        if usr_table < ug_table
          join_table = "#{usr_table}_#{ug_table}"
        else
          join_table = "#{ug_table}_#{usr_table}"
        end
        Lockdown.user_group_class.find_by_sql <<-SQL
            select #{ug_table}.* from #{ug_table}, #{join_table}
             where #{ug_table}.id = #{join_table}.#{Lockdown.user_group_id_reference}
             and #{join_table}.#{Lockdown.user_id_reference} = #{usr.id}	 
             order by #{ug_table}.name
        SQL
      end
    end

    # Similar to user_groups_assignable_for_user, this method should be
    # used to restrict users from creating a user group with more power than
    # they have been allowed.
    def permissions_assignable_for_user(usr)
      return [] if usr.nil?
      if administrator?(usr)
        get_permissions.collect do |k| 
          ::Permission.find_by_name(Lockdown.get_string(k))
        end.compact
      else
        user_groups_assignable_for_user(usr).collect do |g| 
          g.permissions
        end.flatten.compact
      end
    end

    # Returns and array of permission symbols for the user group
    def permissions_for_user_group(ug)
      sym = Lockdown.get_symbol(ug)
      perm_array = []  

      if has_user_group?(sym)
        permissions = user_groups[sym] || []
      else
        if ug.respond_to?(:permissions)
          permissions = ug.permissions
        else
          raise GroupUndefinedError, "#{ug} not found in init.rb and does not respond to #permissions"
        end
      end


      permissions.each do |perm|
        perm_sym = Lockdown.get_symbol(perm)

        unless permission_exists?(perm_sym)
          msg = "Permission associated to User Group is invalid: #{perm}"
          raise SecurityError, msg
        end

        perm_array << perm_sym
      end

      perm_array 
    end

    def process_rules
      parse_permissions
      validate_user_groups
    end

    private

    def find_permission_object(perm_symbol)
      obj = permission_objects.find{|name, pobj| pobj.name == perm_symbol}
      obj[1] if obj
    end

    def validate_user_groups
      user_groups.each do |user_group, perms|
        perms.each do |perm|
          unless permission_exists?(perm)
            msg ="User Group: #{user_group}, permission not found: #{perm}"
            raise Lockdown::InvalidRuleAssignment, msg
          end
        end
      end
    end

    def parse_permissions
      permission_objects.each do |name, perm|
        @permissions[perm.name] ||= []
        set_controller_access(perm)
      end

      set_model_access
    end

    def set_controller_access(perm)
      perm.controllers.each do |name, controller|
        controller.set_access_methods

        @permissions[perm.name] |= controller.access_methods

        if perm.public_access?
          @public_access |= controller.access_methods
        elsif perm.protected_access?
          @protected_access |= controller.access_methods
        end
      end
    end

    def set_model_access
      method_definition =  "\tdef check_model_authorization\n\t#This method will check for access to model resources\n"

      permission_objects.each do |name, perm|
        next if perm.models.empty?

        #Set filter for each controller
        perm.controllers.each do |controller_name, controller|
          #Set filter for each model on controller
          perm.models.each do |model_name, model|
            method_definition << define_restrict_model_access(controller, model)
          end
        end
      end

      method_definition << "\n\tend"

      Lockdown.add_controller_method method_definition
    end

    def define_restrict_model_access(controller, model)
      controller_class = Lockdown.fetch_controller_class(controller.name)

      methods = controller.
                  access_methods.
                    collect do |am| 
                      am[am.index('/') + 1..-1].to_sym if am.index('/')
                    end.compact.inspect

      return <<-RUBY
        if controller_name == "#{controller.name}" 
          if #{methods}.include?(action_name.to_sym)
            unless instance_variable_defined?(:@#{model.name})
              @#{model.name} = #{model.class_name}.find(params[#{model.param.inspect}])
            end
            # Need to make sure we find the model first before checking admin status. 
            return true if current_user_is_admin? 
            unless @#{model.name}.#{model.model_method}.#{model.association}(#{model.controller_method})
              raise SecurityError, "Access to #\{action_name\} denied to #{model.name}.id #\{@#{model.name}.id\}"
            end
          end
        end
      RUBY
    end
  end
end
