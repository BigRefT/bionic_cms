class SiteMenuItem < ActiveRecord::Base
  acts_as_site_member
  belongs_to :site_menu
  belongs_to :site_route

  validates_presence_of :name
  validates_presence_of :site_route_id, :if => Proc.new { |p| p.redirect_url.nil? || p.redirect_url.blank? }, :message => "and Redirect Url can't be blank."

  acts_as_audited :protect => false

  attr_accessible :name, :site_route_id, :redirect_url, :sub_site_menu_id, :site_menu_id
  
  before_save :flag_draft_new

  def url
    return site_route.url_handle if self.site_route
    return self.redirect_url if self.redirect_url
  end

  def sub_site_menu
    SiteMenu.find(:first, :conditions => ["id = ?", self.sub_site_menu_id || 0])
  end
  alias :sub :sub_site_menu

  def sub_site_menu=(site_menu)
    self.sub_site_menu_id = site_menu.id
  end

  def in_draft_mode?
    !self.live_version.empty_or_nil?
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
  
  def flag_or_destroy!
    if self.draft_new? || !self.site_menu.in_draft_mode?
      self.destroy
    else
      self.draft_delete = true
      self.save
    end
  end
  
  private
  
  def flag_draft_new
    if self.site_menu.in_draft_mode? and self.new_record?
      self.draft_new = true
    end
  end

end
