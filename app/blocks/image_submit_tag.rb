class ImageSubmitTag < Liquid::Tag
  def initialize(tag_name, markup, tokens)
    unless markup =~ SubmitTag::Syntax
      raise Liquid::SyntaxError.new("Syntax Error in 'image_submit_tag' - Valid syntax: image_submit_tag [\"label\"] src:\"image_url\"")
    end

    super(tag_name, markup, tokens)
  end

  def render(context)
    SubmitTag.new("submit_tag", @markup + " image:true", nil).render(context)
  end
end
Liquid::Template.register_tag('image_submit_tag', ImageSubmitTag)