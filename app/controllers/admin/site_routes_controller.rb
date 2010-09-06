class Admin::SiteRoutesController < ApplicationController
  # GET /admin/site_routes
  def index
    if session[:site_route_search].not_nil? && params[:search].nil?
      params[:search] = session[:site_route_search]
    end

    if params[:search]
      session[:site_route_search] = params[:search]
      @site_routes = SiteRoute.search(params[:search], params[:page])
    else
      @site_routes = SiteRoute.paginate(:all, :page => params[:page], :order => 'url_handle')
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/site_routes/new
  def new
    @site_route = SiteRoute.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/site_routes/1/edit
  def edit
    @site_route = SiteRoute.find(params[:id])
  end

  # POST /admin/site_routes
  def create
    @site_route = SiteRoute.new(params[:site_route])

    respond_to do |format|
      if @site_route.save
        flash[:notice] = 'SiteRoute was successfully created.'
        format.html { redirect_to(admin_site_routes_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/site_routes/1
  def update
    @site_route = SiteRoute.find(params[:id])

    respond_to do |format|
      if @site_route.update_attributes(params[:site_route])
        flash[:notice] = 'SiteRoute was successfully updated.'
        format.html { redirect_to(admin_site_routes_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/site_routes/1
  def destroy
    @site_route = SiteRoute.find(params[:id])
    @site_route.destroy

    respond_to do |format|
      flash[:warning] = "SiteRoute was successfully deleted."
      format.html { redirect_to(admin_site_routes_url) }
    end
  end
end
