class SelectBlock < Liquid::Block
  Syntax = /("?\S+"?)/

  def initialize(tag_name, markup, tokens)
    if markup =~ Syntax
      @name = $1
      @attributes = {}
      markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value
      end
    else
      raise Liquid::SyntaxError.new("Syntax Error in 'select' - Valid syntax: select [attribute]")
    end

    super(tag_name, markup, tokens)
  end

  def render(context)
    @context = context
    parse_attributes

    rvalue = []
    rvalue << "<div class=\"fieldWithErrors\">" if form_options[:error_found]
    rvalue << "<select#{html_attributes}>"
    @context.stack do
      @context['select_value'] = parse_attribute(@select_value).to_s
      rvalue << render_all(@nodelist, @context)
    end
    rvalue << "</select>"
    rvalue << "</div>" if form_options[:error_found]

    # clear the attribute_copy so the next
    # pass will get a fresh copy from the original
    @attributes_copy = nil
    # return rendered value
    rvalue
  end

  private
    include Bionic::LiquidFormHelpers

  def html_attributes
    @select_value = attributes.delete('value')
    super
  end

end
Liquid::Template.register_tag('select', SelectBlock)