module Lockdown
  class Database
    class << self
      # This is very basic and could be handled better using orm specific
      # functionality, but I wanted to keep it generic to avoid creating 
      # an interface for each the different orm implementations. 
      # We'll see how it works...
      def sync_with_db

        @permissions = Lockdown::System.get_permissions
        @user_groups = Lockdown::System.get_user_groups

        unless ::Permission.table_exists? && Lockdown.user_group_class.table_exists?
          Lockdown.logger.info ">> Lockdown tables not found.  Skipping database sync."
          return
        end
        create_new_permissions

        delete_extinct_permissions
      
        maintain_user_groups
      rescue Exception => e
        Lockdown.logger.error ">> Lockdown sync failed: #{e.backtrace.join("\n")}" 
      end

      # Create permissions not found in the database
      def create_new_permissions
        @permissions.each do |key|
          next if Lockdown::System.permission_assigned_automatically?(key)
          str = Lockdown.get_string(key)
          p = ::Permission.find(:first, :conditions => ["name = ?", str])
          unless p
            Lockdown.logger.info ">> Lockdown: Permission not found in db: #{str}, creating."
            ::Permission.create(:name => str)
          end
        end
      end

      # Delete the permissions not found in init.rb
      def delete_extinct_permissions
        db_perms = ::Permission.find(:all).dup
        db_perms.each do |dbp|
          unless @permissions.include?(Lockdown.get_symbol(dbp.name))
            Lockdown.logger.info ">> Lockdown: Permission no longer in init.rb: #{dbp.name}, deleting."
          ug_table = Lockdown.user_groups_hbtm_reference.to_s
          if "permissions" < ug_table
            join_table = "permissions_#{ug_table}"
          else
            join_table = "#{ug_table}_permissions"
          end
            Lockdown.database_execute("delete from #{join_table} where permission_id = #{dbp.id}")
            dbp.destroy
          end
        end
      end

      def maintain_user_groups
        # Create user groups not found in the database
        @user_groups.each do |key|
          str = Lockdown.get_string(key)
          unless ug = Lockdown.user_group_class.find(:first, :conditions => ["name = ?", str])
            create_user_group(str, key)
          else
            # Remove permissions from user group not found in init.rb
            remove_invalid_permissions(ug, key)

            # Add in permissions from init.rb not found in database
            add_valid_permissions(ug, key)
          end
        end
      end

      def create_user_group(name_str, key)
        Lockdown.logger.info ">> Lockdown: #{Lockdown::System.fetch(:user_group_model)} not in the db: #{name_str}, creating."
        ug = Lockdown.user_group_class.create(:name => name_str)
        #Inefficient, definitely, but shouldn't have any issues across orms.
        #
        Lockdown::System.permissions_for_user_group(key).each do |perm|

          if Lockdown::System.permission_assigned_automatically?(perm)
            Lockdown.logger.info  ">> Permission #{perm} cannot be assigned to #{name_str}.  Already belongs to built in user group (public or protected)."
            raise  InvalidPermissionAssignment, "Invalid permission assignment"
          end

          p = ::Permission.find(:first, :conditions => ["name = ?", Lockdown.get_string(perm)]) 

          ug_table = Lockdown.user_groups_hbtm_reference.to_s
          if "permissions" < ug_table
            join_table = "permissions_#{ug_table}"
          else
            join_table = "#{ug_table}_permissions"
          end
          Lockdown.database_execute "insert into #{join_table}(permission_id, #{Lockdown.user_group_id_reference}) values(#{p.id}, #{ug.id})"
        end
      end

      def remove_invalid_permissions(ug, key)
        ug.permissions.each do |perm|
          perm_sym = Lockdown.get_symbol(perm)
          perm_string = Lockdown.get_string(perm)
          unless Lockdown::System.permissions_for_user_group(key).include?(perm_sym)
            Lockdown.logger.info ">> Lockdown: Permission: #{perm_string} no longer associated to User Group: #{ug.name}, deleting."
            ug.permissions.delete(perm)
          end
        end
      end

      def add_valid_permissions(ug, key)
        Lockdown::System.permissions_for_user_group(key).each do |perm|
          perm_string = Lockdown.get_string(perm)
          found = false
          # see if permission exists
          ug.permissions.each do |p|
            found = true if Lockdown.get_string(p) == perm_string 
          end
          # if not found, add it
          unless found
            Lockdown.logger.info ">> Lockdown: Permission: #{perm_string} not found for User Group: #{ug.name}, adding it."
            p = ::Permission.find(:first, :conditions => ["name = ?", perm_string])
            ug.permissions << p
          end
        end
      end

    end # class block
  end # Database
end #Lockdown
