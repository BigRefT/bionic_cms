class FormForRemoteBlock < FormForBlock

  # <item_id:##> <method:post> <class:form_class> <id:form_id> <multipart:false>
  def initialize(tag_name, markup, tokens)
    super(tag_name, markup, tokens)
    if @attributes['update'].empty_or_nil?
      raise Liquid::SyntaxError.new("Syntax Error in 'form_for_remote' - Valid syntax: form_for [form_action] update:[element_id]")
    end
  end

  def render(context)
    @context = context
    parse_action

    @update_id = attributes.delete('update')

    loading_action = attributes.delete('loading')
    if loading_action
      loading_action = ", onLoading:function(request){#{parse_attribute(loading_action)}}"
    end

    loaded_action = attributes.delete('loaded')
    if loaded_action
      loaded_action = ", onLoaded:function(request){#{parse_attribute(loaded_action)}}"
    end

    parameters = "{asynchronous:true, evalScripts:true#{loaded_action}#{loading_action}, parameters:Form.serialize(this)}"
    ajax_call = "\"new Ajax.Updater('#{parse_attribute(@update_id)}', '#{@action}', #{parameters}); return false;\""
    attributes['onsubmit'] = ajax_call
    super(@context)
  end

  private

  def hidden_fields
    rvalue = super
    rvalue << HiddenFieldTag.new("hidden_field_tag", "update_id value:#{parse_attribute(@update_id)}", nil).render(@context)
    rvalue
  end

end
Liquid::Template.register_tag('form_for_remote', FormForRemoteBlock)