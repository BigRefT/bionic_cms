class Admin::SiteEmailsController < ApplicationController
  before_filter :load_site_snippets, :only => [:new, :edit]

  def index
    available_notifiers = Bionic::EmailSettings.instance.notifiers.sort { |a, b| a[:name] <=> b[:name] }

    @notifier_emails = []
    available_notifiers.each do |notifier|
      notifier_emails = { :notifier => notifier[:name] }
      notifier_emails[:site_emails] = SiteEmail.find_all_by_notifier_name(notifier[:name])
      @notifier_emails << notifier_emails
    end
    
    @contact_form_emails = []
    CustomNotifier.find_all_by_notifier_type('ContactForm').each do |custom_notifier|
      notifier_emails = { :notifier => custom_notifier.name }
      notifier_emails[:site_emails] = SiteEmail.find_all_by_notifier_name(custom_notifier.name)
      @contact_form_emails << notifier_emails
    end

  end

  # GET /admin/site_emails/new
  def new
    @site_email = SiteEmail.new(:notifier_name => params[:notifier_name])
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/site_emails/:id/edit
  def edit
    @site_email = SiteEmail.find(params[:id])
  end

  def create
    @site_email = SiteEmail.new(params[:site_email])

    respond_to do |format|
      if @site_email.save
        flash[:notice] = "SiteEmail: #{@site_email.full_name} was successfully updated."
        format.html { redirect_to(admin_site_emails_url) }
      else
        load_site_snippets
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @site_email = SiteEmail.find(params[:id])

    respond_to do |format|
      if @site_email.update_attributes(params[:site_email])
        flash[:notice] = "SiteEmail: #{@site_email.full_name} was successfully updated."
        format.html { redirect_to(admin_site_emails_url) }
      else
        load_site_snippets
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/site_emails/:id
  def destroy
    @site_email = SiteEmail.find(params[:id])
    @site_email.destroy

    respond_to do |format|
      flash[:warning] = "SiteEmail: #{@site_email.full_name} was successfully deleted."
      format.html { redirect_to(admin_site_emails_url) }
    end
  end
  
  def activate
    @site_email = SiteEmail.find(params[:id])

    respond_to do |format|
      @site_email.active = true
      if @site_email.save
        flash[:notice] = "SiteEmail: #{@site_email.full_name} was successfully activated."
      else
        flash[:error] = "SiteEmail: #{@site_email.full_name} could not be activated"
      end
      format.html { redirect_to(admin_site_emails_url) }
    end
  end
  
  def deactivate
    @site_email = SiteEmail.find(params[:id])

    respond_to do |format|
      @site_email.active = false
      if @site_email.save
        flash[:notice] = "SiteEmail: #{@site_email.full_name} was successfully deactivated."
      else
        flash[:error] = "SiteEmail: #{@site_email.full_name} could not be deactivated"
      end
      format.html { redirect_to(admin_site_emails_url) }
    end
  end

  private
  
  def load_site_snippets
    @site_snippets = SiteSnippet.find(:all, :order => "name")
  end

end
