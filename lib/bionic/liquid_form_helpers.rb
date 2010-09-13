module Bionic
  module LiquidFormHelpers
    include ERB::Util

    def render_attribute(key, value)
      " #{key}=\"#{html_escape(parse_attribute(value))}\""
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

    def parse_attributes
      return if @form_options.not_nil?
      load_form_options
      parse_value
      parse_id
      parse_name
    end

    def form_options
      @form_options ||= {
        :found_in_model => false,
        :error_found => false,
        :objeck_has_errors => false,
        :found_value => "",
        :form_model => nil,
        :register_key => nil
      }
    end

    def load_form_options
      unless @context['form_model'].empty_or_nil?
        form_options[:form_model] = @context['form_model']
        form_options[:register_key] = @context['form_register_key']
        if @context.registers[form_options[:register_key]] # get object
          form_options[:objeck_has_errors] = !@context.registers[form_options[:register_key]].errors.empty?
          if @context.registers[form_options[:register_key]].respond_to?(@name.to_sym) # does it have the field
            form_options[:found_value] = @context.registers[form_options[:register_key]].send(@name.to_sym).to_s
            form_options[:error_found] = @context.registers[form_options[:register_key]].errors.invalid?(@name.to_sym)
            form_options[:found_in_model] = true
          end
        end
      end
    end

    def parse_value
      default_value = @attributes.delete('default_value')
      if @attributes['value'].empty_or_nil?
        @attributes['value'] = if form_options[:found_in_model]
          if form_options[:found_value].empty_or_nil? && !form_options[:objeck_has_errors]
            @context[default_value] || ""
          else
            form_options[:found_value]
          end
        else
          @context[default_value] || ""
        end
      end
    end

    def parse_name
      if @attributes['name'].empty_or_nil?
        if form_options[:form_model].not_nil? && form_options[:found_in_model]
          value = "#{form_options[:form_model]}[#{@name.underscore}]"
        else
          value = "#{context_value(@name).to_s.underscore}"
        end
        @attributes['name'] = value
      end
    end

    def parse_id
      if @attributes['id'].empty_or_nil?
        if form_options[:form_model].not_nil? && form_options[:found_in_model]
          value = "#{form_options[:form_model]}_#{@name.underscore}"
        else
          value = "#{context_value(@name).to_s.underscore}"
        end
        @attributes['id'] = value
      end
    end

    def html_attributes
      html_attributes = ""
      @attributes.each do |key, value|
        html_attributes += render_attribute(key, value)
      end
      html_attributes
    end

  end
end