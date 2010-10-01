class TimeSelectTag < FieldTag
  def initialize(tag_name, markup, tokens)
    begin
      super(tag_name, markup, tokens)
    rescue Liquid::SyntaxError => e
      raise Liquid::SyntaxError.new("Syntax Error in 'time_select' - Valid syntax: time_select [name]")
    end
  end

  private

  def field_html
    # get date value
    value = parse_attribute(attributes.delete('value'))
    value = DateTime.parse(value) if value.is_a? String
    twelve_hour = parse_attribute(attributes.delete('twelve_hour')).to_boolean
    minute_step = parse_attribute(attributes.delete('minute_step')).to_i

    time_options = {
      :tag => true, #forces the creation of hidden date fields
      :field_name => @name,
      :prefix => parse_attribute(attributes.delete('prefix')) || @form_options[:form_model],
      :include_position => true,
      :time_separator => parse_attribute(attributes.delete('time_separator')) || " : ",
      :twelve_hour => twelve_hour
    }
    time_options[:minute_step] = minute_step if minute_step > 0

    # delete name/id from attributes
    attributes.delete('name')
    attributes.delete('id')
    attributes.symbolize_keys!

    DateTimeSelector.new(value, time_options, attributes).select_time
  end

end
Liquid::Template.register_tag('time_select', TimeSelectTag)