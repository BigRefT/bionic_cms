module Admin::SiteSnippetsHelper
  
  def site_snippet_draft_toggle_link
    if @site_snippet.in_draft_mode?
      rvalue = link_to 'Publish Draft', publish_draft_admin_site_snippet_url(@site_snippet), :method => :post
      rvalue += " | "
      rvalue += link_to 'Live Version Content', live_content_admin_site_snippet_url(@site_snippet), :id => 'live_content', :title => 'Live Version Content'
      site_snippet_live_content_window
    else
      rvalue = link_to 'Start Draft', start_draft_admin_site_snippet_url(@site_snippet), :method => :post
    end
    rvalue
  end
  
  def site_snippet_live_content_window(content_id = "live_content")
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
        "   var live_content = window_factory($('#{content_id}'));\n" <<
        "});\n")
    end
  end

end
