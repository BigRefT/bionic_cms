class CheckBoxFieldTag < Liquid::Tag
  
  def initialize(tag_name, markup, tokens)
    unless markup =~ TextFieldTag::Syntax
      raise Liquid::SyntaxError.new("Syntax Error in 'check_box_field' - Valid syntax: check_box_field [name]")
    end

    super(tag_name, markup, tokens)
  end

  def render(context)
    TextFieldTag.new("text_field", @markup + " value:1 checkbox:true", nil).render(context)
  end
end
Liquid::Template.register_tag('check_box_field', CheckBoxFieldTag)