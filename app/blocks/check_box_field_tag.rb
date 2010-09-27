class CheckBoxFieldTag < Liquid::Tag
  
  def initialize(tag_name, markup, tokens)
    unless markup =~ FieldTag::Syntax
      raise Liquid::SyntaxError.new("Syntax Error in 'check_box_field' - Valid syntax: check_box_field [name]")
    end

    super(tag_name, markup, tokens)
  end

  def render(context)
    additional_markup = " checkbox:true"
    # if no value then assume boolean (0,1)
    additional_markup += " value:1" unless @markup.include? " value:"
    TextFieldTag.new("text_field", @markup + additional_markup, nil).render(context)
  end
end
Liquid::Template.register_tag('check_box_field', CheckBoxFieldTag)