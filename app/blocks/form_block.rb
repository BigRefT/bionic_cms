class FormBlock < Liquid::Block
  def initialize(tag_name, markup, tokens)
     super 
     @form_action = markup
  end

  def render(context)
    @context = context
    result = []
    result << "<form method=\"post\" action=\"#{parse_attribute(@form_action)}\">"
    result << "<div style=\"margin: 0pt; padding: 0pt;\"><input type=\"hidden\" value=\"#{@context.registers['form_authenticity_token']}\" name=\"authenticity_token\"/></div>"
    result << render_all(@nodelist, @context)
    result << "</form>"
    result
  end

private

  def parse_attribute(value)
    if value =~ Bionic::QuotedAttribute
      $1 || $2
    else
      @context[value] || value
    end
  end
end
Liquid::Template.register_tag('form', FormBlock)