class FlashDrop < Liquid::Drop
  include ERB::Util

  def initialize(flash)
    @flash = flash
    @flash_messages = []
    @flash.each do |key, value|
      @flash_messages << FlashMessageDrop.new(key, value)
    end
  end

  def before_method(message)
    value = @flash[message.to_sym]
    value.empty_or_nil? ? nil : FlashMessageDrop.new(message.to_sym, value)
  end
  
  def format
    rvalue = ""
    @flash_messages.each do |message|
      next unless ['notice', 'error', 'warning'].include? message.key
      rvalue += message.format
    end
    rvalue
  end
  
  def format_all
    rvalue = ""
    @flash_messages.each do |message|
      rvalue += message.format
    end
    rvalue
  end
  
  def messages
    @flash_messages
  end
end

class FlashMessageDrop < Liquid::Drop
  include ERB::Util

  def initialize(key, value)
    @key = key
    @value = value
  end
  
  def key
    @key.to_s
  end
  
  def value
    html_escape(@value)
  end
  
  def format
    return '' if value.empty_or_nil?
    "<div id=\"flash_#{key}_id\" class=\"flash_#{key}\">#{value}</div>"
  end
end