module Admin::SiteAssetsHelper
  def display_type_image_or_thumb(site_asset)
    if site_asset.image_type?
      return image_tag(site_asset.url(:thumb), :size => "32x32")
    else
      if ['text/html'].include? site_asset.asset_content_type
        image_tag('admin/icons/mime/html.gif')
      elsif ['text/css'].include? site_asset.asset_content_type
        image_tag('admin/icons/mime/css.gif')
      elsif ['text/js', 'application/x-javascript'].include? site_asset.asset_content_type
        image_tag('admin/icons/mime/js.gif')
      elsif ['application/zip'].include? site_asset.asset_content_type
        image_tag('admin/icons/mime/zip.gif')
      elsif ['application/pdf'].include? site_asset.asset_content_type
        image_tag('admin/icons/mime/pdf.gif')
      else
        image_tag('admin/icons/mime/generic.gif')
      end
    end
  end
end
