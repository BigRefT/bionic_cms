class RadioFieldTag < Liquid::Tag
  # <length:##> <class:form_class> <id:form_id>
  def initialize(tag_name, markup, tokens)
    unless markup =~ FieldTag::Syntax
      raise Liquid::SyntaxError.new("Syntax Error in 'radio_field' - Valid syntax: radio_field [name]")
    end

    super(tag_name, markup, tokens)
  end

  def render(context)
    TextFieldTag.new("text_field", @markup + " radio:true", nil).render(context)
  end
end
Liquid::Template.register_tag('radio_field', RadioFieldTag)