module Admin::SiteMenusHelper

  def site_menu_draft_toggle_link(site_menu)
    if site_menu.in_draft_mode?
      rvalue = link_to 'Publish Draft', publish_admin_site_menu_url(site_menu), :method => :post
      rvalue += " | "
      rvalue += link_to 'Live Version Content', live_content_admin_site_menu_url(site_menu), :id => "live_content_#{site_menu.id}", :title => 'Live Version Content'
      site_snippet_live_content_window("live_content_#{site_menu.id}")
    else
      rvalue = link_to 'Start Draft', draft_admin_site_menu_url(site_menu), :method => :post
    end
    rvalue
  end

end
