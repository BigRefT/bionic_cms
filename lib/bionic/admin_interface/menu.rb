class Bionic::AdminInterface::Menu
  attr_reader :links, :handle
  attr_accessor :label, :link

  class DuplicateMenuItemNameError < StandardError; end

  def initialize(label, link = nil)
    @links = []
    @label = label
    @link = link
    @handle = label.to_handle
  end

  def add(label, url, options = {})
    raise DuplicateMenuItemNameError.new("duplicate menu item name `#{label}'") if find_by_label(label)
    new_link =Bionic::AdminInterface::MenuItem.new(label, url)
    if options[:first]
      @links.unshift new_link
    elsif options[:before] # default to first if not found
      index = @links.empty? ? 0 : (@links.index(find_by_label(options[:before])) || 0)
      @links.insert(index, new_link)
    elsif options[:after] # default to last if not found
      index = @links.empty? ? 0 : (@links.index(find_by_label(options[:after])) || @links.size - 1)
      @links.insert(index + 1, new_link)
    else
      @links << new_link
    end
  end

  def find_by_label(label)
    @links.detect { |menu_item| menu_item.label == label }
  end

  def delete_by_url(url)
    return nil if url.nil?
    @links.delete_if { |menu_item| url == menu_item.url }
  end

  def delete(label)
    return nil if label.nil?
    @links.delete_if { |menu_item| label == menu_item.label }
  end
  
  def has_links?
    @links.length > 0
  end
  
  def includes_link?(path)
    @links.detect { |link| path =~ /^#{link.url.gsub('/', '\/')}/ }.not_nil?
  end
end