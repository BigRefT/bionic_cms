class HomeController < ApplicationController
  include Bionic::ModelHelpers
  layout 'application'
  
  ssl_required :show_login_page

  def ssl_allowed?
    return false if ssl_required?
    true
  end

  def show_page
    flash.keep # keep flash around 
    if Site.current_site_id
      url = parse_url_param
      return if url_is_special?(url)

      # find the route without query parameters
      @site_route = SiteRoute.find_by_url_handle(url, request.query_string)
      if @site_route # route found
        if @site_route.routeable # if we have an object

          # if page is not published then send to home with 404
          unless @site_route.routeable.published?
            render_with_status(404) and return
          end

          return unless can_access_page?(@site_route.routeable)
          # see if ssl required
          return if ssl_redirect(@site_route.routeable.ssl_required?)

          # get content type from layout.
          # if page layout not defined then return blank
          content_type = if @site_route.routeable.site_layout
            @site_route.routeable.site_layout.active_revision(Site.draft_mode).content_type
          else
            ""
          end

          render(
            :text => @site_route.routeable.render(
              self,
              standard_assigns.merge(session[:liquid_assigns] || {}),
              standard_registers.merge(session[:liquid_registers] || {})
            ),
            :content_type => content_type
          )
          # clear info from resource redirects (see Bionic::ModelHelpers)
          session[:liquid_assigns] = nil
          session[:liquid_registers] = nil
        else # no object so just a redirect
          if @site_route.status_301? # if 301 then set status
            redirect_to @site_route.redirect_url, :status => 301
          else
            redirect_to @site_route.redirect_url
          end
        end
      else # route not found so redirect with 404
        render_with_status(404) and return
      end
    else # no site id - so admin is browsing the site without a site specified
      flash[:notice] = "No current site. Select a site to view it's pages."
      redirect_to logged_in? ? '/admin' : '/login' # send them to admin or login
    end
  end

  def show_login_page
    login_page = Page.find_login_page
    if login_page
      render(
        :text => login_page.render(
          self,
          standard_assigns("/login").merge(session[:liquid_assigns] || {}),
          standard_registers.merge(session[:liquid_registers] || {})
        ),
        :content_type => login_page.site_layout.active_revision(Site.draft_mode).content_type
      )
    else
      redirect_to :controller => 'sessions', :action => 'new'
    end
  end
  
  def toggle_draft_mode
    mode = params[:mode].empty_or_nil? ? 'live' : params[:mode]
    
    if mode == 'draft'
      session[:draft_mode] = true
      flash[:notice] = "Draft Mode..."
      new_link_text = "enter live mode"
      new_link_url = end_draft_mode_url
    else
      session[:draft_mode] = nil
      flash[:notice] = "Live Mode..."
      new_link_text = "enter draft mode"
      new_link_url = begin_draft_mode_url
    end
    preserve_draft_mode

    respond_to do |format|
      format.html { redirect_to Site.current_site_id ? "http://#{Site.current_site.domain}/" : home_url }
      format.js {
        flash[:notice] = nil # clear flash if javascript used
        render(
          :partial => 'toggle_draft_mode',
          :locals => { :new_link_text => new_link_text, :new_link_url => new_link_url },
          :layout => false
        )
      }
    end
  end
  
  def contact
    contact_form = ContactForm.new(params[:contact_form])
    contact_form.custom_notifier_method = "contact_email"
    if contact_form.valid?
      custom_filters = CustomNotifier.with_notifier_type_and_name("ContactForm", contact_form.form_name)
      if custom_filters.length > 0
        Notifier.custom_trigger_contact_email(contact_form.to_hash)
        flash[:notice] = "#{contact_form.form_name} form successfully submitted."
        show_success
      else
        contact_form.errors.add(:form_name, "improperly configured (form_name not found in Contact Form Notifiers).")
        show_failure(contact_form)
      end
    else
      show_failure(contact_form)
    end
  end

private

  def parse_url_param
    url = params[:url]
    if Array === url
      url = url.join('/')
    else
      url = url.to_s
    end
    url == "/" ? url : "/" + url
  end

  def url_is_special?(url)
    if url =~ /\/images|assets[\?\/]?/
      render :text => '404 - public file not found.', :status => 404, :content_type => SiteLayout.default_content_type
      return true
    end
    false
  end

  def can_access_page?(page)
    unless current_user_can_access_page?(page)
      if logged_in?
        # if logged in then mark as 401 - Access Denied
        render_with_status(401)
        return false
      else
        redirect_to login_url
        return false
      end
    end
    true
  end

  def render_with_status(status)
    page = Page.find_by_status(status)
    if can_access_page?(page)
      render(
        :text => page.render(self, { 'current_page' => page.url, 'status' => status.to_s }),
        :status => status.to_i,
        :content_type => page.site_layout.active_revision(Site.draft_mode).content_type
      )
    end
  end
  
  def standard_assigns(current_page = nil)
    { 'current_page' => current_page || @site_route.url_handle,
      'previous_page' => session[:previous_page],
      'query_string' => QueryStringDrop.new(@current_url_hash),
      'form_params' => form_params }
  end
  
  def standard_registers
    {}
  end
  
  def form_params
    if request.method == :post
      current_params_hash = {}
      params.each do |key, val|
        next if [:url, :controller, :action, :authenticity_token].include?(key.to_sym)
        current_params_hash[key.to_sym] = val if !key.empty_or_nil? && !val.empty_or_nil?
      end
      FormParamsDrop.new(current_params_hash)
    end
  end
end
