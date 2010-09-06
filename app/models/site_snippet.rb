class SiteSnippet < ActiveRecord::Base
  validates_presence_of   :name
  validates_uniqueness_of :name, :scope => :site_id
  validates_proper_liquid_syntax :content

  acts_as_audited :protect => false

  attr_accessible :name, :content, :content_type

  acts_as_site_member

  class << self
    def per_page
      15
    end

    def search(search, page)
      paginate :page => page, :conditions => ['lower(name) like lower(?)', "%#{search}%"], :order => 'name'
    end
    
    def find_content_by_name(name)
      return '' if name.empty_or_nil?
      found = find(:first, :conditions => { :name => name })
      found.empty_or_nil? ? '' : found.content
    end
  end
  
  def is_text?
    self.content_type == 'plain text'
  end
  
  def is_html?
    self.content_type == 'html'
  end
  
  def in_draft_mode?
    return false if new_record?
    return !self.live_version.empty_or_nil?
  end
  
  def live
    return self unless in_draft_mode?
    found_revision = self.revision(self.live_version)
    found_revision || self
  end

  def active_revision(site_in_draft_mode = nil)
    site_in_draft_mode.empty_or_nil? || site_in_draft_mode == false ? self.live : self
  end
  
  def current_version
    current_version = self.audits.find(:first, :order => "version DESC")
    current_version ? current_version.version : 1
  end
  
end
