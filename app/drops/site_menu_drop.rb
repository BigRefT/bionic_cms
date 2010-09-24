class SiteMenuDrop < Liquid::Drop

  def initialize(site_menu)
    @site_menu = site_menu
  end

  def name
    @site_menu.name
  end
  
  def handle
    @site_menu.handle
  end
  
  def items
    rvalue = []
    @site_menu.active_item_revisions(@context['site'].draft_mode).each do |site_menu_item|
      rvalue << SiteMenuItemDrop.new(site_menu_item)
    end
    rvalue
  end

end