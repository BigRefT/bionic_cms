class SubmitTag < Liquid::Tag
  Syntax = /("[\w\.\s]+"|[\w\.]+)/
  def initialize(tag_name, markup, tokens)
    if markup =~ Syntax
      @input_label = $1
      @attributes = {}
      markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value
      end
    else
      raise Liquid::SyntaxError.new("Syntax Error in 'submit_tag' - Valid syntax: submit_tag [\"label\"]")
    end

    super(tag_name, markup, tokens)
  end

  def render(context)
    html_attributes = success_url = ""
    input_type = "submit"

    asset_name = @attributes.delete('asset_name')
    if asset_name && @attributes['src'].empty_or_nil? && ['true', '"true"'].include?(@attributes['image'])
      @attributes['src'] = "/assets/#{Site.current_site_id || 'admin'}/original/#{parse_attribute(asset_name)}"
    end

    @attributes.each do |key, value|
      case key
      when 'value' # skip
      when 'success_url'
        success_url = HiddenFieldTag.new("hidden_field_tag", "success_url #{render_success_url("value", value, context)}", nil).render(context)
      when 'image'
        input_type = "image" if ['true', '"true"'].include?(value)
      else
        html_attributes += render_attribute(key, value, context)
      end
    end
    
    rvalue = success_url
    value = render_attribute("value", @input_label, context)
    rvalue += "<input type=\"#{input_type}\" #{value}#{html_attributes}>"
    rvalue
  end

  private
  
  def render_success_url(key, value, context)
    rvalue = render_attribute(key, value, context)
    rvalue.gsub("=", ":")
  end

  def render_attribute(key, value, context)
    " #{key}=\"#{parse_attribute(value)}\""
  end

  def parse_attribute(value)
    if value =~ Bionic::QuotedAttribute
      $1
    else
      context_value(value)
    end
  end

  def context_value(value)
    @context[value] || value
  end

end
Liquid::Template.register_tag('submit_tag', SubmitTag)