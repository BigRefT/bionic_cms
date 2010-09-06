class OptionTag < FieldTag

  def initialize(tag_name, markup, tokens)
    super(tag_name, markup, tokens)
  end

  private

  def html_attributes
    @option_text = @attributes.delete('text')
    html_attributes = super
    if @context['select_value'].to_s == @attributes['value'].to_s
      html_attributes += render_attribute('selected', 'selected')
    end
    html_attributes
  end

  def field_html
    rvalue = "<option#{html_attributes}>"
    rvalue += html_escape(parse_attribute(@option_text))
    rvalue += "</option>"
    rvalue
  end

  # tidy up: no need for id or name in label
  def parse_id; end
  def parse_name; end

end
Liquid::Template.register_tag('option', OptionTag)