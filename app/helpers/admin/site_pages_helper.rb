module Admin::SitePagesHelper
  
  def page_type_options
    if @page.new_record?
      if params[:theme].nil?
        types = SitePage.page_types_for_select
      else
        types = ThemePage.page_types_for_select
      end
    else
      types = @page.class.page_types_for_select
    end
    types.sort_by { |p| p.first }
  end
  
  def show_all?
    false
  end
 
  def expanded_rows
    unless @expanded_rows
      @expanded_rows = case
      when rows = cookies[:expanded_rows]
        rows.split(',').map { |x| Integer(x) rescue nil }.compact
      else
        []
      end
 
      if homepage and !@expanded_rows.include?(homepage.id)
        @expanded_rows << homepage.id
      end
    end
    @expanded_rows
  end

  def homepage
    @homepage ||= SitePage.find_top_pages.first
  end
 
  def expanded(site_page)
    show_all? || expanded_rows.include?(site_page.id)
  end
 
  def padding_left(level)
    (level * 26) + 4
  end

  def children_class(site_page)
    unless site_page.children.empty?
      if expanded(site_page)
        " children-visible"
      else
        " children-hidden"
      end
    else
      " no-children"
    end
  end
  
  def expander(site_page)
    unless site_page.children.empty?
      image_tag((expanded(site_page) ? "admin/icons/collapse.png" : "admin/icons/expand.png"),
            :class => "expander", :alt => 'toggle children',
            :title => '')
    else
      ""
    end
  end

  def spinner(site_page)
    image_tag('admin/icons/loading.gif',
            :class => 'busy', :id => "busy-#{site_page.id}",
            :alt => "", :title => "",
            :style => 'display: none;', :size => "12x12")
  end

  def site_page_part_draft_toggle_link(part)
    if part.in_draft_mode?
      rvalue = link_to 'Publish Part', publish_draft_admin_site_page_site_page_part_url(part.page, part), :method => :post
      rvalue += " | "
      rvalue += link_to 'Live Part', live_content_admin_site_page_site_page_part_url(part.page, part), :id => "live_content_#{part.id}", :title => 'Live Version Content'
      site_page_part_live_content_window(part.id)
    else
      rvalue = link_to 'Draft Part', start_draft_admin_site_page_site_page_part_url(part.page, part), :method => :post
    end
    rvalue
  end
  
  def site_page_part_live_content_window(part_id)
    additional_script do
      javascript_include_tag(['livepipe/livepipe', 'livepipe/resizable', 'livepipe/window']) +
      javascript_tag("document.observe('dom:loaded',function(){\n" <<
        "  //styled examples use the window factory for a shared set of behavior\n" <<
        "  var window_factory = function(container,options){\n" <<
        "    var window_header = new Element('div',{\n" <<
        "      className: 'window_header'\n" <<
        "    });\n" <<
        "    var window_title = new Element('div',{\n" <<
        "      className: 'window_title'\n" <<
        "    });\n" <<
        "     var window_close = new Element('div',{\n" <<
        "       className: 'window_close'\n" <<
        "     });\n" <<
        "     var window_contents = new Element('div',{\n" <<
        "       className: 'window_contents'\n" <<
        "     });\n" <<
        "     var w = new Control.Window(container,Object.extend({\n" <<
        "       className: 'window',\n" <<
        "       closeOnClick: window_close,\n" <<
        "       draggable: window_header,\n" <<
        "       method: 'get',\n" <<
        "       resizable: true,\n" <<
        "       insertRemoteContentAt: window_contents,\n" <<
        "       afterOpen: function(){\n" <<
        "         window_title.update(container.readAttribute('title'))\n" <<
        "       }\n" <<
        "     }, options || {}));\n" <<
        "     w.container.insert(window_header);\n" <<
        "     window_header.insert(window_title);\n" <<
        "     window_header.insert(window_close);\n" <<
        "     w.container.insert(window_contents);\n" <<
        "     return w;\n" <<
        "   };\n" <<
        "\n" <<
        "   var live_content_#{part_id} = window_factory($('live_content_#{part_id}'));\n" <<
        "});\n")
    end
  end
end
