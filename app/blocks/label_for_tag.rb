class LabelForTag < FieldTag
  def initialize(tag_name, markup, tokens)
    begin
      super(tag_name, markup, tokens)
    rescue Liquid::SyntaxError => e
      raise Liquid::SyntaxError.new("Syntax Error in 'label_for' - Valid syntax: label_for [name]")
    end
  end

  private

  def html_attributes
    @label_text = attributes.delete('text')
    @label_text ||= "#{@name.titleize}"

    if attributes['for'].empty_or_nil?
      if form_options[:form_model]
        attributes['for'] = "#{form_options[:form_model]}_#{@name.underscore}"
      else
        attributes['for'] = "#{context_value(@name).to_s.underscore}"
      end
    end
    super
  end

  def field_html
    "<label#{html_attributes}>#{context_value(@label_text)}</label>"
  end

  # tidy up: no need for id, value, or name in label
  def parse_value; end
  def parse_id; end
  def parse_name; end

end
Liquid::Template.register_tag('label_for', LabelForTag)