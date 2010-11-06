# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement

  layout 'admin/bionic'
  protect_from_forgery
  prepend_before_filter :get_site_from_hostname, :set_status

  def render_optional_error_file(status_code)
    # don't render any error files from public
    # and always go to the home page
    flash[:error] = "Unexpected Error: We are sorry for the inconvenience and have been notified of the problem."
    redirect_to "/"
  end

  def template_name
    case self.action_name
    when 'index'
      'index'
    when 'new','create'
      'new'
    when 'show'
      'show'
    when 'edit', 'update'
      'edit'
    when 'remove', 'destroy'
      'remove'
    else
      self.action_name
    end
  end

  private

  def set_status
    ensure_proper_protocol
    preserve_draft_mode
    check_profile_cookie
    save_url_params
    store_previous_page
  end

  def store_previous_page
    if valid_store_location?
      session[:previous_page] = session[:this_page] || '/'
    end
    session[:this_page] = sent_from_uri
  end

  def valid_store_location?
    return false unless request.method == :get
    return false if session[:this_page] == sent_from_uri
    return false if session[:this_page] && session[:this_page].start_with?("/forms/")
    return false if SiteRoute.store_location_excludes.include?(session[:this_page])
    true
  end

  def get_site_from_hostname
    # if the domain name changed or we are here for the first time
    if request_host != session[:domain_name] || session[:domain_name].nil?
      logger.info "=> Bionic: Resetting session because of domain change."
      reset_session
      session[:domain_name] ||= request_host
      session[:current_site_id] ||= Site.find_id_by_domain(session[:domain_name])
    end
    Site.current_site_id = session[:current_site_id]
  end

  def check_profile_cookie
    return unless session[:user_profile_id].empty_or_nil?
    session[:user_profile_id] = Profile.find_id_by_cookie_token(cookies[:user_profile_id])
  end

  def save_url_params
    @current_url_hash = request.query_string.split('&').inject({}) do |hash, setting|
      key, val = setting.split('=')
      hash[key.to_sym] = val if !key.empty_or_nil? && !val.empty_or_nil?
      hash
    end
  end

  def preserve_draft_mode
    Site.draft_mode = session[:draft_mode]
  end
end
