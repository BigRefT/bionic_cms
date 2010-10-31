class CalendarDateSelectTag < FieldTag
  def initialize(tag_name, markup, tokens)
    begin
      super(tag_name, markup, tokens)
    rescue Liquid::SyntaxError => e
      raise Liquid::SyntaxError.new("Syntax Error in 'calendar_date_select' - Valid syntax: calendar_date_select [name]")
    end
  end

  private

  def parse_value
    default_value = attributes.delete('default_value')
    if ["'today'", "today", "\"today\""].include? default_value
      attributes['default_value'] = Date.today
    elsif ["'now'", "now", "\"now\""].include? default_value
      attributes['default_value'] = Time.now
    end
    super
  end

  def parse_custom
    attributes.select { |attribute| ['embedded', 'buttons', 'disabled', 'readonly', 'hidden'].include?(attribute) }.each do |key, value|
      attributes[key] = parse_attribute(value).to_boolean
    end
    attributes['minute_interval'] = parse_attribute(attributes['minute_interval']).to_i if attributes['minute_interval']
    if attributes['time']
      unless value =~ /mixed/
        attributes['time'] = parse_attribute(attributes['time']).to_boolean
      end
    end
  end

  def field_html
    attributes.symbolize_keys!
    attributes.each { |key, value| attributes[key] = parse_attribute(value) }
    calendar_date_select_tag(attributes.delete(:name), attributes.delete(:value), attributes)
  end

end
Liquid::Template.register_tag('calendar_date_select', CalendarDateSelectTag)