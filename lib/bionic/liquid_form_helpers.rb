module Bionic
  module LiquidFormHelpers
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

    def render_attribute(key, value)
      " #{key}=\"#{html_escape(parse_attribute(value))}\""
    end

    def parse_attribute(value)
      if value =~ Bionic::QuotedAttribute
        $1 || $2
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
      parse_custom
    end

    def form_options
      @form_options ||= {
        :found_in_model => false,
        :error_found => false,
        :objeck_has_errors => false,
        :found_value => "",
        :form_model => nil,
        :register_key => nil,
        :found_array => false,
        :found_value_array => []
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
          else
            # look for format of model[attribute][] for arrays
            if !attributes['name'].empty_or_nil? && parse_attribute(attributes['name']) =~ /[\w]+\[([\w]+)\]\[\]/
              modified_name = $1
              if @context.registers[form_options[:register_key]].respond_to?(modified_name.to_sym) # does it have the field
                form_options[:found_value_array] = @context.registers[form_options[:register_key]].send(modified_name.to_sym)
                # make sure it's an array
                if form_options[:found_value_array].is_a?(Array)
                  # convert all members to strings
                  form_options[:found_value_array] = form_options[:found_value_array].each(&:to_s)
                  form_options[:error_found] = @context.registers[form_options[:register_key]].errors.invalid?(modified_name.to_sym)
                  form_options[:found_in_model] = true
                  form_options[:found_array] = true
                else
                  form_options[:found_value_array] = []
                end
              end
            end
          end
        end
      end
    end

    def parse_value
      default_value = attributes.delete('default_value')
      if attributes['value'].empty_or_nil?
        value = if form_options[:found_in_model]
          if form_options[:found_value].empty_or_nil? && !form_options[:objeck_has_errors]
            @context[default_value].to_s
          else
            form_options[:found_value]
          end
        else
          @context[default_value].to_s
        end
        # add quotes to avoid parsing the value any more
        attributes['value'] = value.empty_or_nil? ? "" : "\"#{value}\""
      end
    end

    def parse_name
      if attributes['name'].empty_or_nil?
        value = if form_options[:form_model].not_nil? && form_options[:found_in_model]
          "#{form_options[:form_model]}[#{@name.to_s.underscore}]"
        else
          context_value(@name).to_s.underscore
        end
        # add quotes to avoid parsing the value any more
        attributes['name'] = value.empty_or_nil? ? "" : "\"#{value}\""
      end
    end

    def parse_id
      if attributes['id'].empty_or_nil?
        value = if form_options[:form_model].not_nil? && form_options[:found_in_model]
          "#{form_options[:form_model]}_#{@name.to_s.underscore}"
        else
          context_value(@name).to_s.underscore
        end
        # add quotes to avoid parsing the value any more
        attributes['id'] = value.empty_or_nil? ? "" : "\"#{value}\""
      end
    end

    def parse_custom
      # here for easy extending
    end

    def html_attributes
      html_attributes = ""
      attributes.each do |key, value|
        html_attributes += render_attribute(key, value)
      end
      html_attributes
    end

    # make a copy of the original so we can cover the case of this tag being in a for loop.
    # In this case the first interation will be fine, but if the tag/block deletes an attribute
    # then the second iteration will be missing that attribute.
    def attributes
      # leave the original alone
      @attributes_copy ||= @attributes.dup
    end

  end
end