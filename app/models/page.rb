class Page < ActiveRecord::Base
  acts_as_audited :protect => false

  set_inheritance_column :class_name
  before_save :save_default_values

  belongs_to :site_layout
  has_many :site_routes, :as => :routeable, :dependent => :destroy
  has_many :parts, :class_name => 'SitePagePart', :order => 'id', :dependent => :destroy
  has_and_belongs_to_many :user_groups

  attr_accessor :url_handle, :content

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :site_id
  validates_proper_liquid_syntax :content

  attr_accessible :name, :title, :meta_keywords, :meta_description,
                  :published, :content, :breadcrumb, :url_handle,
                  :site_layout_id, :published_at, :parts, :ssl_required

  acts_as_tree
  acts_as_site_member

  class << self
    def find_top_pages
      SitePage.find :all, :conditions => 'parent_id is null', :order => 'site_id'
    end
    
    def per_page
      15
    end

    def search(search, page)
      paginate :page => page, :conditions => ['lower(name) like lower(?)', "%#{search}%"], :order => 'name'
    end

    def find_by_status(status)
      page = nil
      if status.to_i == 404
        page = Page.find_file_not_find_pages.first
      elsif status.to_i == 401
        page = Page.find_access_denied_pages.first
      end
      page = Page.find_top_pages.first unless page
      page
    end

    def find_file_not_find_pages
      ThemePage.find(:all, :conditions => ["class_name = ? AND published = ?", "FileNotFoundThemePage", true])
    end

    def find_access_denied_pages
      ThemePage.find(:all, :conditions => ["class_name = ? AND published = ?", "AccessDeniedThemePage", true])
    end

    def find_login_page
      return nil unless Site.current_site_id
      ThemePage.find(:first, :conditions => ["class_name = ? AND published = ?", "LoginThemePage", true])
    end
  end

  def add_site_route(url_to_add, is_main_route = false)
    return if url_to_add.nil? || url_to_add.blank?
    self.site_routes << SiteRoute.new(:url_handle => url_to_add, :main_route => is_main_route)
  end

  def apply_access_rights_to_children
    children.each do |child|
      child.user_groups = self.user_groups
      child.allow_public_access = self.allow_public_access
      child.allow_registered_users = self.allow_registered_users
      child.save
      child.apply_access_rights_to_children
    end
  end

  def part(name)
    if new_record? or parts.to_a.any?(&:new_record?)
      parts.to_a.find {|p| p.name == name.to_s }
    else
      parts.find_by_name name.to_s
    end
  end

  def has_part?(name)
    !part(name).nil?
  end

  def main_route
    self.site_routes.find(:first, :conditions => "main_route = true")
  end

  def articles
    rvalue = children.find(:all, :conditions => ["class_name = ?", 'ArticleSitePage'])
    children.each { |child| rvalue += child.articles }
    rvalue.sort! { |a, b| b.published_at <=> a.published_at }
    rvalue
  end

  def url
    main_route ? main_route.url_handle : nil
  end

  def breadcrumbs
    rvalue = []
    if self.url
      rvalue << {:url => self.url, :name => self.breadcrumb}
      if parent
        rvalue = parent.breadcrumbs + rvalue
      end
    else
      rvalue = Page.find_top_pages.first.breadcrumbs << {:url => "", :name => self.breadcrumb}
    end
    rvalue
  end

  def render(kontroller, assigns = {}, registers = {})
    # load page and content for parse and render
    assigns = render_assigns(kontroller).merge(assigns)
    registers = render_registers(kontroller).merge(registers)
    filters = render_filters
    # clean up
    kontroller.send(:flash).discard
    # parse the page parts
    self.parts.each do |part|
      parsed_part = Liquid::Template.parse(part.active_revision(Site.draft_mode).content)
      parsed_part_with_snippets = Liquid::Template.parse(parsed_part.render(assigns, :filters => filters, :registers => registers))
      rendered_part = parsed_part_with_snippets.render(assigns, :filters => filters, :registers => registers)
      assigns["#{part.name.to_handle}_part"] = rendered_part
      assigns["page_content"] = rendered_part if part.name == 'body'
    end
    # parse the layout
    parsed_layout = Liquid::Template.parse(self.site_layout.active_revision(Site.draft_mode).content)
    # parse the render of the layouts to filter anything added by a snippet
    parsed_with_snippets = Liquid::Template.parse(parsed_layout.render(assigns, :filters => filters, :registers => registers))
    # render the snippet
    return parsed_with_snippets.render(assigns, :filters => filters, :registers => registers)
  end

  def always_public?
    false
  end

  def theme_page?
    false
  end

  private

    def render_assigns(kontroller)
      assigns = {
        'page' => SitePageDrop.new(self),
        'menus' => SiteMenuCollectionDrop.new, # moved to site - TODO - delete
        'flash' => FlashDrop.new(kontroller.send(:flash)), # moved to site - TODO - delete
        'user' => UserDrop.new(kontroller.send(:current_user), kontroller.send(:current_profile)),
        'environment' => Rails.env, # moved to site - TODO - delete
        'form_authenticity_token' => kontroller.send(:form_authenticity_token), # moved to site - TODO - delete
        'site' => SiteDrop.new(kontroller)
      }
      Bionic::Extension.descendants.each do |ext|
        assigns.merge! ext.instance.liquid_assigns
      end
      assigns.each do |key, value|
        assigns[key] = value.call(kontroller) if value.is_a? Proc
      end
      assigns['draft_mode'] = true unless Site.draft_mode.empty_or_nil?
      assigns
    end

    def render_filters
      Liquid::Strainer.filters
    end
    
    def render_registers(kontroller)
      { 'form_authenticity_token' => kontroller.send(:form_authenticity_token),
        :controller => kontroller }
    end

    def save_default_values
      self.title = self.title.empty_or_nil? ? self.name : self.title
      self.breadcrumb = self.breadcrumb.empty_or_nil? ? self.name : self.breadcrumb
      self.meta_keywords = self.meta_keywords.empty_or_nil? ? self.name : self.meta_keywords
      self.meta_description = self.meta_description.empty_or_nil? ? self.name : self.meta_description
    end
end