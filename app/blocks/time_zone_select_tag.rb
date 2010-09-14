class TimeZoneSelectTag < FieldTag
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

  def initialize(tag_name, markup, tokens)
    begin
      super(tag_name, markup, tokens)
    rescue Liquid::SyntaxError => e
      raise Liquid::SyntaxError.new("Syntax Error in 'time_zone_select' - Valid syntax: time_zone_select [name]")
    end
  end

  private

  def field_html
    @default = parse_attribute(@attributes.delete('default')) || Time.zone
    @include_blank = parse_attribute(@attributes.delete('include_blank')).to_boolean

    if form_options[:found_in_model]
      rvalue = time_zone_select(
        @form_options[:form_model],
        @name.to_s.underscore,
        ::ActiveSupport::TimeZone.us_zones,
        :default => @default,
        :include_blank => @include_blank
      )
    else
      rvalue = select_tag(
        @name.to_s.underscore,
        time_zone_options_for_select(@default, ::ActiveSupport::TimeZone.us_zones),
        :include_blank => @include_blank
      )
    end
    rvalue
  end

end
Liquid::Template.register_tag('time_zone_select', TimeZoneSelectTag)