class Notifier < ActionMailer::Base
  adv_attr_accessor :recipient_email

  class << self

    def method_missing(method_symbol, *parameters) #:nodoc:
      if match = matches_dynamic_method?(method_symbol)
        case match[1]
          # create and deliver are expection
          # <method_name>_<site_email_id>
          when 'create'
            site_email = load_site_email(match[2])
            return nil if site_email.nil?
            if method_match = matches_bionic_dynamic_method?(match[2])
              new(method_match[1], site_email, *parameters).mail
            else
              nil
            end
          when 'deliver'
            site_email = load_site_email(match[2])
            return nil if site_email.nil?
            if method_match = matches_bionic_dynamic_method?(match[2])
              mail_object = new(method_match[1], site_email, *parameters)
              mail_object.deliver! # unless mail_object.body.empty_or_nil?
            else
              nil
            end
          when 'trigger' then trigger(match[2], *parameters)
          when 'custom_trigger' then custom_trigger(match[2], *parameters)
          when 'new'     then nil
          else super
        end
      else
        super
      end
    end

    def load_site_email(method_name = nil)
      return nil if method_name.nil?
      # get site_email_id from method_name
      # <method_name>_<site_email_id>
      if match = matches_bionic_dynamic_method?(method_name)
        site_email_id = match[2].to_i
      end
      return nil if site_email_id.nil?
      site_email = SiteEmail.find(:first, :conditions => ['id = ?', site_email_id])
      return nil if site_email.nil?
      site_email
    end
    
    def trigger(method_name = nil, *parameters) #:nodoc:
      return false if method_name.nil?
      site_emails = SiteEmail.find_all_active_by_notifier_name(method_name.camelize)
      site_emails.each do |site_email|
        Delayed::Job.enqueue(
          Bionic::NotifierJob.new(Site.current_site_id, Site.draft_mode, method_name, site_email.id, parameters),
          0,
          site_email.number_of_days_after_to_send.days.from_now
        )
      end
      true
    end

    def custom_trigger(method_name = nil, *parameters) #:nodoc:
      return false if method_name.nil?
      notifier_name = custom_notifier_type = nil
      if parameters.length > 0
        notifier_name = parameters.first["form_name"]
        custom_notifier_method = parameters.first["custom_notifier_method"]
      end
      return false if notifier_name.empty_or_nil?

      # emails to requestor
      site_emails = SiteEmail.find_all_active_by_notifier_name(notifier_name)
      site_emails.each do |site_email|
        Delayed::Job.enqueue(
          Bionic::NotifierJob.new(
            Site.current_site_id,
            Site.draft_mode,
            custom_notifier_method,
            site_email.id,
            parameters
          ),
          0,
          site_email.number_of_days_after_to_send.days.from_now
        )
      end

      # send notice emails
      site_emails = SiteEmail.find_all_active_by_notifier_name("#{notifier_name}Notice")
      notice_parameters = parameters.dup
      notice_parameters.first['notice'] = true
      site_emails.each do |site_email|
        Delayed::Job.enqueue(
          Bionic::NotifierJob.new(
            Site.current_site_id,
            Site.draft_mode,
            custom_notifier_method,
            site_email.id,
            notice_parameters
          ),
          0,
          site_email.number_of_days_after_to_send.days.from_now
        )
      end
      true
    end
    
    private

      def matches_bionic_dynamic_method?(method_name)
        method_name = method_name.to_s
        /^([_a-z]\w*)_(\d*)/.match(method_name)
      end
      
      def matches_dynamic_method?(method_name)
        method_name = method_name.to_s
        /^(create|deliver|trigger|custom_trigger)_([_a-z]\w*)/.match(method_name) || /^(new)$/.match(method_name)
      end

  end

  # override initialize to check for site_email
  # returning if not found
  def initialize(method_name = nil, site_email = nil, *parameters) #:nodoc:
    @site_email = site_email
    super(method_name, *parameters)
  end

  def parse_site_email(assigns)
    parse_site_snippet(@site_email.site_snippet, assigns)
  end

  def load_site_email_attributes
    subject(@site_email.subject) if @site_email.subject
    from(@site_email.from) if @site_email.from
    cc(@site_email.cc_email_array) if @site_email.cc
    bcc(@site_email.bcc_email_array) if @site_email.bcc
    reply_to(@site_email.reply_to_email_array) if @site_email.reply_to
    content_type(@site_email.content_type) if @site_email.content_type
  end
  
  def contact_email(data)
    if data["email"].not_nil? && data["form_name"].not_nil?
      load_site_email_attributes
      if data['notice'].not_nil?
        recipient_email(@site_email.from)
        recipients(@site_email.from)
        from(data["email"])
      else
        recipient_email(data["email"])
        recipients(data["email"])
      end
      @body = parse_site_email({'contact_form' => data })
    end
  end
  
  private
  
  def parse_site_snippet(site_snippet, assigns)
    if site_snippet
      parsed_email = Liquid::Template.parse(site_snippet.active_revision(Site.draft_mode).content)
      parsed_email_with_snippets = Liquid::Template.parse(parsed_email.render(assigns, :filters => render_filters))
      rendered_email = parsed_email_with_snippets.render(assigns, :filters => render_filters)
      rendered_email
    end
    rendered_email || ""
  end

  def render_filters
    Liquid::Strainer.filters
  end

end
