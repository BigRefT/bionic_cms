# Include hook code here
require 'ar_default_options'
require 'acts_as_site_member'
ActiveRecord::Base.send(:include, Bionic::Acts::SiteMembered)