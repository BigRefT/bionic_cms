class HiddenFieldTag < Liquid::Tag
  # <length:##> <class:form_class> <id:form_id>
  def initialize(tag_name, markup, tokens)
    unless markup =~ FieldTag::Syntax
      raise Liquid::SyntaxError.new("Syntax Error in 'hidden_field' - Valid syntax: hidden_field [name]")
    end

    super(tag_name, markup, tokens)
  end

  def render(context)
    TextFieldTag.new("text_field", @markup + " hidden:true", nil).render(context)
  end
end
Liquid::Template.register_tag('hidden_field', HiddenFieldTag)