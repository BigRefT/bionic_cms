class PasswordFieldTag < Liquid::Tag
  # <length:##> <class:form_class> <id:form_id>
  def initialize(tag_name, markup, tokens)
    unless markup =~ FieldTag::Syntax
      raise Liquid::SyntaxError.new("Syntax Error in 'password_field' - Valid syntax: password_field [name]")
    end

    super(tag_name, markup, tokens)
  end

  def render(context)
    TextFieldTag.new("text_field", @markup + " password:true", nil).render(context)
  end
end
Liquid::Template.register_tag('password_field', PasswordFieldTag)