module Admin::DashboardHelper

  def audit_display(audit)
   # begin
      rvalue = ""
      rvalue += "New " if audit.action == "create"
      rvalue += "#{audit.auditable_type.to_readable}: "
      rvalue += auditable_name(audit) || "<< error >>"
      rvalue += " was #{audit_action(audit.action)}" if audit.action != "create"
      rvalue += "<br />"
      rvalue += "<span>at #{audit.created_at.strftime("%I:%M %p").downcase} by #{audit.user ? audit.user.profile.name : 'System'}</span>"
      rvalue
  #  rescue Exception => e
   #   "Something: #{e.message}"
    #end
  end
  
  def audit_url(obj)
    if obj.respond_to? :audit_url
      url = obj.audit_url
      return nil if url.empty_or_nil?
      return eval(url) if url.is_a?(String)
      return url
    end

    if obj.is_a?(SiteMenuItem) || obj.is_a?(SiteMenu)
      return admin_site_menus_url
    elsif obj.is_a?(User)
      if obj.profile
        return ['edit', 'admin', obj.profile]
      else
        return admin_profiles_url
      end
    elsif obj.is_a?(Permission)
      return admin_site_permissions_url
    elsif SitePage.is_descendant_class_name?(obj.class.to_s)
      return admin_site_pages_url
    elsif ThemePage.is_descendant_class_name?(obj.class.to_s)
      return admin_site_pages_url
    else
      return ['edit', 'admin', obj]
    end
  end
  
  def auditable_name(audit)
    rvalue = audit.auditable_type
    begin
      if audit.auditable
        name = "Item"
        if audit.auditable.respond_to? :auditable_name
          name = audit.auditable.auditable_name
        elsif audit.auditable.respond_to? :name
          name = audit.auditable.name
        end

        url_path = audit_url(audit.auditable)
        if url_path.empty_or_nil?
          rvalue = name
        else
          rvalue = link_to(name, url_path)
        end
      else # for deleted items
        if audit.revision.respond_to? :name
          rvalue = audit.revision.name
        end
      end
    rescue
      # nothing
    end
    rvalue
  end
  
  def audit_action(action)
    return "deleted" if action == "destroy"
    return "updated" if action == "update"
  end
end