class TimeZoneSelectTag < FieldTag
  def initialize(tag_name, markup, tokens)
    begin
      super(tag_name, markup, tokens)
    rescue Liquid::SyntaxError => e
      raise Liquid::SyntaxError.new("Syntax Error in 'time_zone_select' - Valid syntax: time_zone_select [name]")
    end
  end

  private

  def field_html
    value = parse_attribute(attributes.delete('value')) || Time.zone
    include_blank = parse_attribute(attributes.delete('include_blank')).to_boolean
    formatted_name = parse_attribute(attributes.delete('name'))
    attributes.symbolize_keys!

    select_tag(
      formatted_name,
      time_zone_options_for_select(value, ::ActiveSupport::TimeZone.us_zones),
      attributes.merge({ :include_blank => include_blank })
    )
  end

end
Liquid::Template.register_tag('time_zone_select', TimeZoneSelectTag)