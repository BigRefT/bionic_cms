class SiteMenuItemDrop < Liquid::Drop

  def initialize(site_menu_item)
    @site_menu_item = site_menu_item
  end

  def name
    @site_menu_item.name
  end
  
  def url
    @site_menu_item.url
  end

  def sub
    @site_menu_item.sub ? SiteMenuDrop.new(@site_menu_item.sub) : nil
  end
  
end