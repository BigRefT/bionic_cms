class SiteLayout < ActiveRecord::Base
  has_many :site_pages

  validates_presence_of   :name, :content
  validates_uniqueness_of :name, :scope => :site_id
  validates_proper_liquid_syntax :content

  acts_as_audited :protect => false

  attr_accessible :name, :content, :active, :content_type

  acts_as_site_member

  class << self
    def per_page
      15
    end

    def search(search, page)
      paginate :page => page, :conditions => ['lower(name) like lower(?)', "%#{search}%"], :order => 'name'
    end
    
    def default_content_type
      "text/html;charset=utf-8"
    end
  end
  
  def content_type
    read_attribute(:content_type).empty_or_nil? ? SiteLayout.default_content_type : read_attribute(:content_type)
  end

  def in_draft_mode?
    return false if new_record?
    return !self.live_version.empty_or_nil?
  end
  
  def live
    return self unless in_draft_mode?
    live_revision = self.revision(self.live_version)
    live_revision || self
  end

  def active_revision(site_in_draft_mode = nil)
    site_in_draft_mode.empty_or_nil? || site_in_draft_mode == false ? self.live : self
  end

  def current_version
    current_version = self.audits.find(:first, :order => "version DESC")
    current_version ? current_version.version : 1
  end

end
