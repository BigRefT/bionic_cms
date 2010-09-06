class Bionic::AdminInterface::MenuSet
  # This may be loaded before ActiveSupport, so do an explicit require
  require 'bionic/admin_interface/menu'
  require 'bionic/admin_interface/menu_item'

  class DuplicateMenuNameError < StandardError; end

  attr_reader :menus

  def initialize
    @menus = []
  end

  def add(label, link = nil, options = {})
    raise DuplicateMenuNameError.new("duplicate menu name `#{label}'") if find_by_label(label)
    new_menu = Bionic::AdminInterface::Menu.new(label, link)
    if options[:first]
      @menus.unshift new_menu
    elsif options[:before] # default to first if not found
      index = @menus.empty? ? 0 : (@menus.index(find_by_label(options[:before])) || 0)
      @menus.insert(index, new_menu)
    elsif options[:after] # default to last if not found
      index = @menus.empty? ? 0 : (@menus.index(find_by_label(options[:after])) || @menus.size - 1)
      @menus.insert(index + 1, new_menu)
    else
      @menus << new_menu
    end
    new_menu.handle
  end
  
  def find_by_label(label)
    @menus.detect { |menu| menu.label == label }
  end

  def find_by_handle(handle)
    @menus.detect { |menu| menu.handle == handle }
  end

  def delete_by_label(label)
    return false if label.nil?
    @menus.delete_if { |menu| label == menu.label }
  end

  def delete(handle)
    return false if handle.nil?
    @menus.delete_if { |menu| handle == menu.handle }
  end

  def method_missing(method, *args, &block)
    menu = find_by_handle(method.to_s)
    if menu
      return menu
    else
      if @menus.respond_to?(method.to_sym)
        @menus.send(method.to_sym, *args, &block)
      else
        super
      end
    end
  end
  
  def respond_to?(method_sym, include_private = false)
    return true if find_by_handle(method_sym.to_s)
    return true if @menus.respond_to?(method_sym.to_s)
    return false
  end
end