# ActsAsSiteMember
module Bionic
  module Acts
    module SiteMembered
      # included is called from the ActiveRecord::Base
      # when you inject this module

      def self.included(base) 
        # Add acts_as_site_member availability by extending the module
        # that owns the function.
        base.extend ClassMethods
      end

      # this module stores the main function and the two modules for
      # the instance and class functions
      module ClassMethods
        def acts_as_site_member(options = {})
          class_eval do
            include Bionic::Acts::SiteMembered::InstanceMethods
            belongs_to :site
            before_validation_on_create :set_site_id
            validates_presence_of :site_id unless options[:allow_null_site_id]
            @use_site_id_in_find_every = true
            @include_null_site_in_find_every = options[:include_null_site_records] ? true : false
            # return_strict_values: true => return only null site id values if current_site_id is null
            #                       false => returns all values if current_site_id is null
            @return_strict_values = options[:return_strict_values] || true
          end
        end
      end # end ClassMethods

      # Istance methods
      module InstanceMethods 
        def set_site_id
          self.site_id = Site.current_site_id
        end
      end # end InstanceMethods
    end
  end
end