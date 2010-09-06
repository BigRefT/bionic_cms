class SiteRoute < ActiveRecord::Base
  acts_as_site_member

  belongs_to :routeable, :polymorphic => true

  validates_presence_of :url_handle
  validates_format_of :url_handle, :with => %r{^/([?&=%-._/A-Za-z0-9]*|/)$}
  validates_uniqueness_of :url_handle, :scope => :site_id, :case_sensitive => false

  acts_as_audited :protect => false
  
  attr_accessible :url_handle, :redirect_url, :status_301, :main_route, :exclude_from_store_location
  
  named_scope :excluded_from_store_location, :conditions => ["exclude_from_store_location = ?", true]

  class << self
    # number of routes per page for will_paginate
    def per_page
      15
    end

    def search(search, page)
      paginate :page => page, :conditions => ['lower(url_handle) like lower(?)', "%#{search}%"], :order => 'url_handle'
    end
    
    def find_by_url_handle(url, query_string = nil)
      conditions = ['lower(url_handle) = lower(?)', url]
      if !query_string.empty_or_nil?
        conditions[0] += ' OR lower(url_handle) = lower(?)'
        conditions << "#{url}?#{query_string}"
      end
      find(:first, :conditions => conditions)
    end
    
    def store_location_excludes
      SiteRoute.excluded_from_store_location.map { |route| route.url_handle } + SiteRoute.standard_store_location_excludes
    end
    
    def select_options(include_blank = true)
      rvalue = include_blank ? [["<Select a Route>", ""]] : []
      rvalue += self.find(:all, :order => "url_handle").collect { |route| [route.url_handle.truncate_url.truncate(:length => 40), route.id] }
      rvalue
    end
    
    def standard_store_location_excludes
      ["/login", "/sessions"]
    end
  end
  
  def name
    url_handle
  end
end
