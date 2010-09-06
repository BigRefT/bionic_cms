class TextFieldTag < FieldTag
  include ERB::Util

  Syntax = /([\w\.]+)/
  # <length:##> <class:form_class> <id:form_id>
  def initialize(tag_name, markup, tokens)
    begin
      super(tag_name, markup, tokens)
    rescue Liquid::SyntaxError => e
      raise Liquid::SyntaxError.new("Syntax Error in 'text_field' - Valid syntax: text_field [name]")
    end
  end

  private

  def html_attributes
    @input_type = "text"
    html_attributes = ""
    @attributes.each do |key, value|
      case key
      when 'hidden'
        @input_type = "hidden"
      when 'password'
        @input_type = "password"
      when 'radio'
        @input_type = "radio"
        if form_options[:found_in_model] && form_options[:found_value] == context_value(@attributes['value']).to_s
          html_attributes += render_attribute("checked", "checked")
        end
        html_attributes.gsub!("id=\"#{@attributes['id']}\"", "id=\"#{@attributes['id']}_#{context_value(@attributes['value'])}\"")
        @attributes['id'] += "_#{@attributes['value']}"
      when 'checkbox'
        @input_type = "checkbox"
        if form_options[:found_in_model] && @context.registers[form_options[:register_key]].send("#{@name}?".to_sym)
          html_attributes += render_attribute("checked", "checked")
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
    rvalue += HiddenFieldTag.new("hidden_field_tag", "#{@name} value:0", nil).render(@context) if @input_type == "checkbox"
    rvalue += "<input type=\"#{@input_type}\"#{html_attribute_string} />"
    rvalue
  end

end
Liquid::Template.register_tag('text_field', TextFieldTag)