class SitePagePart < ActiveRecord::Base
  # Associations
  belongs_to :page
  
  # Validations
  validates_presence_of :name, :content_type
  before_validation :format_attributes
  validates_proper_liquid_syntax :content

  acts_as_audited

  def audit_url
    "admin_site_page_url(#{self.page.id})"
  end
  
  def auditable_name
    "#{self.page.name} - #{self.name}"
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

  private
  
  def format_attributes
    self.content = self.name if new_record?
    self.name = self.name.to_handle unless self.name.empty_or_nil?
  end

end
