module AssetFilter
  def assets_by_tag(tags, assign, order = "ASC")
    site_assets = SiteAsset.tagged_with(tags, :on => :tags).by_display_name(order)
    site_asset_drops = []
    site_asset_drops = site_assets.map { |site_asset| SiteAssetDrop.new(site_asset) }
    assign_to(site_asset_drops, assign)
    nil
  end

  def unique_asset_display_names_by_tag(tags, assign, order = "ASC")
    site_assets = SiteAsset.tagged_with(tags, :on => :tags).by_display_name(order)
    display_names = []
    display_names = site_assets.map{ |asset| asset.display_name }
    display_names.uniq!
    assign_to(display_names, assign)
    nil
  end

  def asset_with_display_name_has_tag(display_name, tags)
    site_assets = SiteAsset.tagged_with(tags, :on => :tags).with_display_name(display_name)
    site_assets.empty? ? nil : SiteAssetDrop.new(site_assets.first)
  end
end