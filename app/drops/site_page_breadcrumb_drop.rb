class SitePageBreadcrumbDrop < Liquid::Drop
  def initialize(breadcrumb)
    @breadcrumb = breadcrumb
  end
  
  def url
    @breadcrumb[:url]
  end
  
  def name
    @breadcrumb[:name]
  end
end