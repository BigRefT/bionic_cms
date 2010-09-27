class TextAreaTag < FieldTag
  def initialize(tag_name, markup, tokens)
    begin
      super(tag_name, markup, tokens)
    rescue Liquid::SyntaxError => e
      raise Liquid::SyntaxError.new("Syntax Error in 'text_area' - Valid syntax: text_area [name]")
    end
  end

  private

  def html_attributes
    @area_value = attributes.delete('value')
    super
  end

  def field_html
    rvalue = "<textarea#{html_attributes}>"
    rvalue += html_escape(context_value(@area_value) || '')
    rvalue += "</textarea>"
  end

end
Liquid::Template.register_tag('text_area', TextAreaTag)