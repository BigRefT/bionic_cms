class SiteMenuCollectionDrop < Liquid::Drop
  def before_method(value)
    if site_menu = SiteMenu.find_by_handle(value)
      SiteMenuDrop.new(site_menu)
    else
      { 'id' => 0, 'name' => "Unknown Menu '#{value}'", 'items' => [] }
    end
  end
end