module Lockdown
  module Orms
    module ActiveRecord
      class << self
        def use_me?
          Object.const_defined?("ActiveRecord") && ::ActiveRecord.const_defined?("Base")
        end

        def included(mod)
          mod.extend Lockdown::Orms::ActiveRecord::Helper
          mixin
        end

        def mixin
          Lockdown.orm_parent.class_eval do
            include Lockdown::Orms::ActiveRecord::Stamps
          end
        end
      end # class block

      module Helper
        def orm_parent
          ::ActiveRecord::Base
        end

        def database_execute(query)
          orm_parent.connection.execute(query)
        end

        def database_query(query)
          orm_parent.connection.execute(query)
        end

        def database_table_exists?(klass)
          klass.table_exists?
        end
      end

      module Stamps
        def self.included(base)
          base.class_eval do
            alias_method :create_without_stamps,  :create
            alias_method :create,  :create_with_stamps
            alias_method :update_without_stamps,  :update
            alias_method :update,  :update_with_stamps
          end
        end

        def current_who_did_it
          Thread.current[:who_did_it]
        end

        def create_with_stamps
          pid = current_who_did_it || Lockdown::System.fetch(:default_who_did_it)
          self[:created_by] = pid if self.respond_to?(:created_by) 
          self[:updated_by] = pid if self.respond_to?(:updated_by) 
          create_without_stamps
        end
                  
        def update_with_stamps
          pid = current_who_did_it || Lockdown::System.fetch(:default_who_did_it)
          self[:updated_by] = pid if self.respond_to?(:updated_by)
          update_without_stamps
        end
      end
    end
  end
end
