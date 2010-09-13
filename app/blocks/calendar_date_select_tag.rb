class CalendarDateSelectTag < Liquid::Tag
  include ERB::Util
  include ActionView::Helpers
  include ActionView::Helpers::ActiveRecordHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::AtomFeedHelper
  include ActionView::Helpers::BenchmarkHelper
  include ActionView::Helpers::CacheHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::DebugHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::RecordIdentificationHelper
  include ActionView::Helpers::RecordTagHelper
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::ScriptaculousHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::UrlHelper

  Syntax = /([\w\.]+)/
  # <length:##> <class:form_class> <id:form_id>
  def initialize(tag_name, markup, tokens)
    if markup =~ Syntax
      @name = $1
      @attributes = {}
      markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value
      end
    else
      raise Liquid::SyntaxError.new("Syntax Error in 'calendar_date_select' - Valid syntax: calendar_date_select [name]")
    end

    super(tag_name, markup, tokens)
  end

  def render(context)
    found_in_model = error_found = objeck_has_errors = false
    found_value = ""
    form_model = nil
    
    unless context['form_model'].empty_or_nil?
      form_model = context['form_model']
      register_key = context['form_register_key']
      if context.registers[register_key] # get object
        objeck_has_errors = !context.registers[register_key].errors.empty?
        if context.registers[register_key].respond_to?(@name.to_sym) # does it have the field
          found_value = context.registers[register_key].send(@name.to_sym)
          error_found = context.registers[register_key].errors.invalid?(@name.to_sym)
          found_in_model = true
        end
      end
    end

    default_value = @attributes.delete('default_value')
    if ["'today'", "today", "\"today\""].include? default_value
      default_value = Date.today
    elsif ["'now'", "now", "\"now\""].include? default_value
      default_value = Time.now
    end

    if @attributes['value'].empty_or_nil?
      @attributes['value'] = if found_in_model
        if found_value.empty_or_nil? && !objeck_has_errors
          default_value || nil
        else
          found_value
        end
      else
        default_value || nil
      end
    end

    if @attributes['name'].empty_or_nil?
      if form_model.not_nil? && found_in_model
        value = "#{form_model}[#{@name.underscore}]"
      else
        value = "#{(context[@name] || @name).to_s.underscore}"
      end
      @attributes['name'] = value
    end

    if @attributes['id'].empty_or_nil?
      if form_model.not_nil? && found_in_model
        value = "#{form_model}_#{@name.underscore}"
      else
        value = "#{(context[@name] || @name).to_s.underscore}"
      end
      @attributes['id'] = value
    end
    
    @attributes.each do |key, value|
      case key
      when 'name', 'value'
        # nothing
      when 'embedded', 'buttons', 'disabled', 'readonly', 'hidden'
        @attributes[key.to_sym] = ["true", "1"].include?(strip_quotes(value))
      when 'minute_interval'
        @attributes[key.to_sym] = strip_quotes(value).to_i
      when 'time'
        @attributes[key.to_sym] = ["true", "1"].include?(strip_quotes(value))
        @attributes[key.to_sym] = value if value =~ /mixed/
      else
        @attributes[key.to_sym] = strip_quotes(value)
      end
    end
    

    rvalue = ""
    rvalue += "<div class=\"fieldWithErrors\">" if error_found
    rvalue += calendar_date_select_tag(@attributes.delete('name'), @attributes.delete('value'), @attributes)
    rvalue += "</div>" if error_found
    rvalue
  end

  private

  def strip_quotes(value)
    value =~ Bionic::QuotedAttribute ? $1 : value
  end

end
Liquid::Template.register_tag('calendar_date_select', CalendarDateSelectTag)