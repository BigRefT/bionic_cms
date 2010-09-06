class SitePageDrop < Liquid::Drop

  def initialize(site_page)
    @site_page = site_page
  end

  def title
    @site_page.title
  end

  def name
    @site_page.name
  end

  def articles
    rvalue = []
    @site_page.articles.each do |article|
      rvalue << SitePageDrop.new(article)
    end
    rvalue
  end
  
  def children
    rvalue = []
    @site_page.children.find(:all, :conditions => ['published = ?', true], :order => "published_at DESC").each do |child|
      rvalue << SitePageDrop.new(child)
    end
    rvalue
  end

  def all_children
    rvalue = []
    @site_page.children.find(:all, :order => "published_at DESC").each do |child|
      rvalue << SitePageDrop.new(child)
    end
    rvalue
  end
  
  def parent
    return nil if @site_page.parent.nil?
    SitePageDrop.new(@site_page.parent)
  end

  def url
    @site_page.url
  end

  def published_at
    @site_page.published_at
  end
  
  def published?
    @site_page.published?
  end

  def meta_keywords
    @site_page.meta_keywords
  end

  def meta_description
    @site_page.meta_description
  end

  def breadcrumbs
    rvalue = []
    @site_page.breadcrumbs.each do |breadcrumb|
      rvalue << SitePageBreadcrumbDrop.new(breadcrumb)
    end
    rvalue
  end

  def before_method(value)
    if value =~ /([\w]+)_part/
      found = @site_page.part($1)
      found.nil? ? nil : found.active_revision(@context['draft_mode']).content
    end
  end

end