class Admin::SitesController < ApplicationController
  # GET /admin/sites
  def index
    if params[:search]
      @sites = Site.search(params[:search], params[:page])
    else
      @sites = Site.paginate(:all, :page => params[:page], :order => 'name')
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/sites/new
  def new
    @site = Site.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/sites/1/edit
  def edit
    @site = Site.find(params[:id])
  end

  # POST /admin/sites
  def create
    @site = Site.new(params[:site])

    respond_to do |format|
      if @site.save
        flash[:notice] = 'Site was successfully created.'
        format.html { redirect_to(admin_sites_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/sites/1
  def update
    @site = Site.find(params[:id])

    respond_to do |format|
      if @site.update_attributes(params[:site])
        flash[:notice] = 'Site was successfully updated.'
        format.html { redirect_to(admin_sites_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/sites/1
  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      flash[:warning] = "Site was successfully deleted."
      format.html { redirect_to(admin_sites_url) }
    end
  end

  # POST /admin/sites/filter_site
  def filter_site
    session[:current_site_id] = params[:site_id] && !params[:site_id].blank? ? params[:site_id].to_i : nil

    respond_to do |format|
      format.html { redirect_to dashboard_admin_path }
    end
  end

end
