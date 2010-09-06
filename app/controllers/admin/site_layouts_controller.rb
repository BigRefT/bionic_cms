class Admin::SiteLayoutsController < ApplicationController
  # GET /admin/site_layouts
  def index
    if session[:site_layout_search].not_nil? && params[:search].nil?
      params[:search] = session[:site_layout_search]
    end

    if params[:search]
      session[:site_layout_search] = params[:search]
      @site_layouts = SiteLayout.search(params[:search], params[:page])
    else
      @site_layouts = SiteLayout.paginate(:all, :page => params[:page], :order => 'name')
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/site_layouts/new
  def new
    @site_layout = SiteLayout.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/site_layouts/:id/edit
  def edit
    @site_layout = SiteLayout.find(params[:id])
  end

  # POST /admin/site_layouts
  def create
    @site_layout = SiteLayout.new(params[:site_layout])

    respond_to do |format|
      if @site_layout.save
        flash[:notice] = "SiteLayout: #{@site_layout.name} was successfully created."
        format.html { redirect_to(admin_site_layouts_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/site_layouts/:id
  def update
    @site_layout = SiteLayout.find(params[:id])

    respond_to do |format|
      if @site_layout.update_attributes(params[:site_layout])
        flash[:notice] = "SiteLayout: #{@site_layout.name} was successfully updated."
        format.html { redirect_to(admin_site_layouts_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/site_layouts/:id
  def destroy
    @site_layout = SiteLayout.find(params[:id])
    @site_layout.destroy

    respond_to do |format|
      flash[:warning] = "SiteLayout: #{@site_layout.name} was successfully deleted."
      format.html { redirect_to(admin_site_layouts_url) }
    end
  end

  # POST /admin/site_layouts/:id/start_draft
  def start_draft
    toggle_draft_mode(:current, 'Could not enter in to Draft Mode!')
  end
  
  # POST /admin/site_layouts/:id/publish_draft
  def publish_draft
    toggle_draft_mode
  end

  # POST /admin/site_layouts/:id/live_content
  def live_content
    @site_layout = SiteLayout.find(params[:id])

    respond_to do |format|
      format.html {
        render :text => @site_layout.live.content, :layout => false, :content_type => "text/plain"
      }
      format.js { render :layout => false } # live_content.js.erb
    end
  end
  
  private
  
  def toggle_draft_mode(version = nil, error_message = 'Could not make live!')
    @site_layout = SiteLayout.find(params[:id])

    SiteLayout.without_auditing do
      @site_layout.live_version = version == :current ? @site_layout.current_version : version
      if @site_layout.save
        flash[:notice] = 'SiteLayout was successfully updated.'
      else
        flash[:error] = error_message
      end
    end

    respond_to do |format|
      format.html { redirect_to(edit_admin_site_layout_url(@site_layout)) }
    end
  end

end
