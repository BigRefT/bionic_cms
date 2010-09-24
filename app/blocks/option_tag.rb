class OptionTag < FieldTag

  def initialize(tag_name, markup, tokens)
    super(tag_name, markup, tokens)
  end

  private

  def html_attributes
    html_attributes = super
    if @context['select_value'].to_s == parse_attribute(@attributes['value']).to_s
      html_attributes += render_attribute('selected', 'selected')
    end
    html_attributes
  end

  def field_html
    text = @attributes.delete('text')
    option_text = html_escape(parse_attribute(text))
    rvalue = "<option#{html_attributes}>"
    rvalue += option_text
    rvalue += "</option>"

    # put the text variable back incase we are in called in a for block
    # in this case if we delete then the next interation will not have text
    # I am only doing it for option and leaving the others alone for now
    # TODO - put all deletes back for all custom tags and blocks
    @attributes['text'] = text
    rvalue
  end

  # tidy up: no need for id or name in label
  def parse_id; end
  def parse_name; end

end
Liquid::Template.register_tag('option', OptionTag)