require 'cgi'

module BionicFilter
  include ActionView::Helpers
  
  def cgi_escape(input)
    CGI.escape(input) rescue input
  end
  alias_method :cgi_h, :cgi_escape

  def javascript_include(name)
    return "" if name.empty_or_nil?
    javascript_include_tag(name == "defaults" ? name.to_sym : name)
  end

  def asset_javascript_include(file_name)
    return "" if file_name.empty_or_nil?
    javascript_include_tag "/assets/#{Site.current_site_id || 'admin'}/original/#{file_name.strip.gsub(/[^\w\d\.\-]+/, '_')}"
  end

  def stylesheet_include(name)
    return "" if name.empty_or_nil?
    stylesheet_link_tag name
  end

  def asset_stylesheet_include(file_name)
    return "" if file_name.empty_or_nil?
    stylesheet_link_tag "/assets/#{Site.current_site_id || 'admin'}/original/#{file_name.strip.gsub(/[^\w\d\.\-]+/, '_')}"
  end

  def link(text, path)
    return "" if text.empty_or_nil? || path.empty_or_nil?
    link_to text, path
  end
  
  def link_to_delete(text, path, message)
    "<a onclick=\"#{delete_on_click(message)}\" href=\"#{path}\">#{text}</a>"
  end

  def link_to_remote(text, onclick)
    "<a onclick=\"#{onclick}\" href=\"#\">#{text}</a>"
  end

  def image(image_path)
    return "" if image_path.empty_or_nil?
    image_tag image_path
  end

  def assign_to(value, assign)
    return if assign.empty_or_nil?
    @context[assign] = value
    nil
  end

  def asset_image(image_path, style = "original")
    return "" if image_path.empty_or_nil?
    image_tag "/assets/#{Site.current_site_id || 'admin'}/#{style}/#{image_path}"
  end

  def asset_image_url(image_path, style = "original")
    "/assets/#{Site.current_site_id || 'admin'}/#{style}/#{image_path}"
  end
  alias :asset_url :asset_image_url

  def link_to_original_asset(text, file_name)
    return "" if text.empty_or_nil?
    link_to text, "/assets/#{Site.current_site_id || 'admin'}/original/#{file_name.strip.gsub(/[^\w\d\.\-]+/, '_')}"
  end

  def site_route_exist(site_route, prefix)
    url_handle = prefix.strip.downcase.gsub(/[^\w\d\.\-\/]+/, '-') + site_route.strip.downcase.gsub(/[^\w\d\.\-\/]+/, '-')
    site_routes = SiteRoute.find(:all, :conditions => ['url_handle = ?', url_handle])
    site_routes.empty? ? nil : site_routes.first.name
  end

  def snippet(name)
    rvalue = ""
    snippet = SiteSnippet.find_by_name(name)
    rvalue = snippet.active_revision(@context['site'].draft_mode).content if snippet
    rvalue
  end
  
  private
  
  def delete_on_click(message)
    rvalue = <<-MSG
      if (confirm('#{message}')) {
        var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        var m = document.createElement('input');
        m.setAttribute('type', 'hidden');
        m.setAttribute('name', '_method');
        m.setAttribute('value', 'delete');
        f.appendChild(m);
        var s = document.createElement('input');
        s.setAttribute('type', 'hidden');
        s.setAttribute('name', 'authenticity_token');
        s.setAttribute('value', '#{@context.registers['form_authenticity_token']}');
        f.appendChild(s);
        f.submit();
      };
      return false;"
    MSG
  end
end

Liquid::Template.register_filter BionicFilter