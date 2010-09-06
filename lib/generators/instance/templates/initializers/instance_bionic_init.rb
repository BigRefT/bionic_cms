module Bionic
  module Admin
    require 'bionic/admin_interface'

    def admin_interface
      AdminInterface.instance
    end
  end
end

ActionController::Base.class_eval do
 include Bionic::Admin
end

ActionController::Base.class_eval do 
  helper_method :admin_interface
end

Paperclip.interpolates :current_site_id do |attachment, style|
  Site.current_site_id ? Site.current_site_id.to_s : "admin"
end

ActionView::Base.default_form_builder = SemanticFormBuilder

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 10
Delayed::Worker.max_run_time = 10.minutes

Audit.send(:acts_as_site_member, {:allow_null_site_id => true})
Tag.send :acts_as_site_member
Tagging.send :acts_as_site_member

# Auto-require lib/core_extensions
Dir["#{BIONIC_ROOT}/lib/core_extensions/*.rb"].each do |core_extension|
  require "core_extensions/#{File.basename(core_extension).sub(/\.rb$/, '')}"
end

# Auto-require BIONIC_ROOT/app/blocks and RAILS_ROOT/app/blocks
(Dir["#{BIONIC_ROOT}/app/blocks/*.rb"] + Dir["#{RAILS_ROOT}/app/blocks/*.rb"]).uniq.each do |block|
  require "#{File.basename(block).sub(/\.rb$/, '')}"
end

# Auto-register BIONIC_ROOT and RAILS_ROOT filters
(Dir["#{BIONIC_ROOT}/app/filters/*.rb"] + Dir["#{RAILS_ROOT}/app/filters/*.rb"]).uniq.each do |liquid_filter|
  require "#{File.basename(liquid_filter).sub(/\.rb$/, '')}"
end