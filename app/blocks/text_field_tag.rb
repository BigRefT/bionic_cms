class TextFieldTag < FieldTag
  def initialize(tag_name, markup, tokens)
    begin
      super(tag_name, markup, tokens)
    rescue Liquid::SyntaxError => e
      raise Liquid::SyntaxError.new("Syntax Error in 'text_field' - Valid syntax: text_field [name]")
    end
  end

  private

  def html_attributes
    @no_hidden_checkbox = parse_attribute(attributes.delete('no_hidden')).to_boolean
    @input_type = "text"
    html_attributes = ""
    attributes.each do |key, value|
      case key
      when 'hidden'
        @input_type = "hidden"
      when 'password'
        @input_type = "password"
      when 'radio'
        @input_type = "radio"
        if form_options[:found_in_model] && form_options[:found_value] == parse_attribute(attributes['value']).to_s
          html_attributes += render_attribute("checked", "checked")
        end
        html_attributes.gsub!("id=\"#{parse_attribute(attributes['id'])}\"", "id=\"#{parse_attribute(attributes['id'])}_#{parse_attribute(attributes['value'])}\"")
        attributes['id'] += "_#{parse_attribute(attributes['value'])}"
      when 'checkbox'
        @input_type = "checkbox"
        if form_options[:found_in_model]
          if form_options[:found_array] && form_options[:found_value_array].include?(parse_attribute(attributes['value']).to_s)
            html_attributes += render_attribute("checked", "checked")
          elsif @context.registers[form_options[:register_key]].respond_to?("#{@name}?".to_sym) && @context.registers[form_options[:register_key]].send("#{@name}?".to_sym)
            html_attributes += render_attribute("checked", "checked")
          end
        end
      else
        html_attributes += render_attribute(key, value)
      end
    end
    html_attributes
  end

  def field_html
    # call before to load @input_type
    html_attribute_string = html_attributes
    # create field
    rvalue = ""
    if @input_type == "checkbox" && !@no_hidden_checkbox
      rvalue += HiddenFieldTag.new(
        "hidden_field_tag",
        "#{@name} id:\"hidden_#{parse_attribute(attributes['id'])}\" name:#{attributes['name']} value:0",
        nil
      ).render(@context)
    end
    rvalue += "<input type=\"#{@input_type}\"#{html_attribute_string} />"
    rvalue
  end

end
Liquid::Template.register_tag('text_field', TextFieldTag)