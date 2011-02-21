class FormForBlock < Liquid::Block
  Syntax = /("?\S+"?)/
  # <item_id:##> <method:post> <class:form_class> <id:form_id> <multipart:false>
  def initialize(tag_name, markup, tokens)
    if markup =~ Syntax
      @form_action = $1
      @attributes = {}
      markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value
      end
    else
      raise Liquid::SyntaxError.new("Syntax Error in 'form_for' - Valid syntax: form_for [form_action]")
    end
    super(tag_name, markup, tokens)
  end

  def render(context)
    @context = context
    parse_action unless @action
    method = 'post'
    html_attributes = ""

    attributes.each do |key, value|
      case key
      when 'method'
        method = parse_attribute(value)
      when 'item_id'
        if @form_model.not_nil?
          item_id = parse_attribute(value)
          # if we have something in the register then we are coming back from save with validation errors
          # in the case of update (not new record) get the id from the record - just to be safe
          if @context.registers[@register_key].not_nil? && !@context.registers[@register_key].new_record?
            item_id = @context.registers[@register_key].id
          end
          # if id not found (not a number greater than zero) then continue as new
          if item_id.to_i > 0
            if @custom_action
              @action = @custom_action[:edit_url]
              @action.gsub!(":id", item_id.to_s)
            else
              @action.gsub!("/create", "/update/#{item_id}")
            end

            if @context.registers[@register_key].nil?
              if @form_model.camelize.constantize.respond_to?(:form_for_find)
                @context.registers[@register_key] = @form_model.camelize.constantize.form_for_find(item_id, @context['user.profile_id'])
                if @context.registers[@register_key].nil?
                  return ["Bionic Error: #{@form_model} with ID=#{item_id} not found"]
                end
              else
                return ["Bionic Error: form_for_find not found in #{@form_model}"]
              end
            end
          end
        end
      when 'multipart'
        html_attributes += " enctype=\"multipart/form-data\"" if parse_attribute(value) == 'true'
      else
        html_attributes += " #{key}=\"#{parse_attribute(value)}\""
      end
    end

    # create a new reocrd if we have a form model but no record
    if @form_model.not_nil? && @context.registers[@register_key].nil?
      @context.registers[@register_key] = @form_model.camelize.constantize.new
    end

    result = []
    result << form_header(method, html_attributes)
    result << "<div style=\"margin: 0pt; padding: 0pt;\">"
    result += hidden_fields
    result << "</div>"

    @context.stack do
      if @form_model.not_nil?
        @context['form_model'] = @form_model
        @context['form_register_key'] = @register_key
        @context['errors_each'] = []
        if @context.registers[@register_key].not_nil?
          @context['error_count'] = @context.registers[@register_key].errors.count
          @context['errors'] = render_errors(@context.registers[@register_key].errors)
          @context.registers[@register_key].errors.each_full { |error| @context['errors_each'] << error.to_s }
        end
      end
      result << render_all(@nodelist, @context)
    end
    result << "</form>"
    # delete form_item_ from register to keep scope
    @context.registers.delete(@register_key) if @form_model.not_nil?
    # clear the attribute_copy so the next
    # pass will get a fresh copy from the original
    @attributes_copy = nil
    # return rendered result
    result
  end
  
  private

  def render_errors(errors)
    return nil if errors.count == 0
    rvalue = "<div id=\"errorExplanation\" class=\"errorExplanation\">"
    rvalue += "<h2>#{@context['errors_header'] || "#{errors.count.to_s} errors prohibited this from being saved"}</h2>"
    rvalue += "<p>#{@context['errors_text'] || "There were problems with the following fields:"}</p>"
    rvalue += "<ul>"
    errors.each_full { |error| rvalue += "<li>#{error}</li>"}
    rvalue += "</ul></div>"
    rvalue
  end

  def form_header(method, html_attributes)
    "<form method=\"#{method}\" action=\"#{@action}\"#{html_attributes}>"
  end

  def hidden_fields
    rvalue = []
    rvalue << HiddenFieldTag.new("hidden_field_tag", "authenticity_token value:#{@context.registers['form_authenticity_token']}", nil).render(@context)
    rvalue << HiddenFieldTag.new("hidden_field_tag", "from_url value:\"#{@context['current_page']}\"", nil).render(@context)
    rvalue << HiddenFieldTag.new("hidden_field_tag", "form_uuid value:\"#{@register_key}\"", nil).render(@context)
    rvalue
  end

  def parse_attribute(value)
    if value =~ Bionic::QuotedAttribute
      $1 || $2
    else
      @context[value] || value
    end
  end

  def parse_action
    raise SyntaxError.new("Syntax Error in 'form_for' - Valid syntax: for_for [form_action]") unless @form_action
    # allow for custom user forms
    # form_for "/some_action"
    if @form_action =~ /"(\S+)"/
      @action = $1
      @form_model = nil
    else
      @custom_action = Bionic::FormForOptions.instance.custom_actions.select { |ca| ca[:form_action] == @form_action }.first
      if @custom_action.not_nil?
        @form_model = @custom_action[:model]
        @action = @custom_action[:new_url]
      else
        @form_model = @form_action
        @action = "/forms/#{@form_model}/create"
      end
      @register_key = "form_#{@form_action}"
      @action = @context.registers[:controller].send(:request).protocol + @context.registers[:controller].send(:request).host + @action
    end
  end

  # make a copy of the original so we can cover the case of this tag being in a for loop.
  # In this case the first interation will be fine, but if the tag/block deletes an attribute
  # then the second iteration will be missing that attribute.
  def attributes
    # leave the original alone
    @attributes_copy ||= @attributes.dup
  end
end
Liquid::Template.register_tag('form_for', FormForBlock)