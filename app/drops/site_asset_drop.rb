class SiteAssetDrop < Liquid::Drop
  def initialize(site_asset)
    @site_asset = site_asset
  end

  def original_url
    @site_asset.url
  end

  def file_name
    @site_asset.file_name
  end

  def name
    @site_asset.name
  end

  def content_type
    @site_asset.asset_content_type
  end

  def file_size
    @site_asset.asset_file_size
  end
end