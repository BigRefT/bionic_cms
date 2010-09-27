# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  include Admin::RegionsHelper

  def display_standard_flashes
    rvalue = ""
    flash.each do |key, value|
      next if value.empty_or_nil?
      rvalue += content_tag 'div', value, :class => "flash_#{key}", :id => "flash_#{key}_id" 
    end
    rvalue
  end

  def row_class(count)
    return '' unless count.is_a?(Integer)
    count % 2 == 1 ? 'odd' : 'even'
  end

  def right_side_partial
    rvalue = "/admin/right_side/standard"
    ActionController::Base.view_paths.each do |view_path|
      if File.exists?("#{view_path}/admin/right_side/#{controller.controller_name}/_#{controller.action_name}.html.erb")
        rvalue = "/admin/right_side/#{controller.controller_name}/#{controller.action_name}"
      end
    end
    rvalue
  end

  def will_paginate_links(collection, options = {})
    will_paginate(collection, options) || empty_pagination_div
  end
  
  def empty_pagination_div
    content_tag(:div, " ", :class => 'pagination')
  end
  
  def will_paginate_record_display(collection)
    return '' if collection.total_entries == 0
    start_record = collection.offset + 1
    end_record = if (collection.per_page > collection.total_entries || (collection.offset + collection.per_page) > collection.total_entries)
      collection.total_entries
    else
      collection.offset + collection.per_page
    end
    "Showing #{start_record} through #{end_record} of #{collection.total_entries}"
  end
  
  def additional_script(script = nil, &block)
    if script
      content_for :additional_script do
        javascript_include_tag script
      end
    else
      content_for :additional_script do
        yield
      end
    end
  end
end