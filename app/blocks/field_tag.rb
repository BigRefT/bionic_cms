class FieldTag < Liquid::Tag
  Syntax = /([\w\.]+)/ unless defined? Syntax

  # <length:##> <class:form_class> <id:form_id>
  def initialize(tag_name, markup, tokens)
    if markup =~ Syntax
      @name = $1
      @attributes = {}
      markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value
      end
    else
      raise Liquid::SyntaxError.new("Syntax Error")
    end
    super(tag_name, markup, tokens)
  end

  def render(context)
    @context = context
    parse_attributes
    result = render_field

    # clear the attribute_copy so the next
    # pass will get a fresh copy from the original
    @attributes_copy = nil
    # return rendered result
    result
  end

  private
    include Bionic::LiquidFormHelpers

  def render_field
    rvalue = ""
    rvalue += "<div class=\"fieldWithErrors\">" if form_options[:error_found]
    rvalue += field_html
    rvalue += "</div>" if form_options[:error_found]
    rvalue
  end

  def field_html
    ""
  end

end