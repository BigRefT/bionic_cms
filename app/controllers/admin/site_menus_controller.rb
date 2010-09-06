class Admin::SiteMenusController < ApplicationController

  # GET /admin/site_menus
  def index
    @site_menus = SiteMenu.find(:all, :order => "name")

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/site_menus/new
  def new
    @site_menu = SiteMenu.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  # POST /admin/site_menus
  def create
    @site_menu = SiteMenu.new(params[:site_menu])
    
    respond_to do |format|
      if @site_menu.save
        flash[:notice] = "SiteMenu - #{@site_menu.name}  was successfully created."
        format.html { redirect_to :action => :index }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  # DELETE /admin/site_menus/:id
  def destroy
    @site_menu = SiteMenu.find(params[:id])
    @site_menu.destroy

    respond_to do |format|
      flash[:warning] = "SiteMenu - #{@site_menu.name} was successfully deleted."
      format.html { redirect_to(admin_site_menus_url) }
    end
  end
  
  # POST /admin/site_menus/:id/draft
  def draft
    @site_menu = SiteMenu.find(params[:id])

    respond_to do |format|
      if @site_menu.begin_draft_mode!
        flash[:notice] = "SiteMenu - #{@site_menu.name} entered draft mode."
      else
        flash[:error] = "SiteMenu - #{@site_menu.name} failed to enter draft mode!"
      end
      format.html { redirect_to(admin_site_menus_url) }
    end
  end
  
  # POST /admin/site_menus/:id/publish
  def publish
    @site_menu = SiteMenu.find(params[:id])

    respond_to do |format|
      if @site_menu.end_draft_mode!
        flash[:notice] = "SiteMenu - #{@site_menu.name} was successfully published."
      else
        flash[:error] = "SiteMenu - #{@site_menu.name} failed to publish!"
      end
      format.html { redirect_to(admin_site_menus_url) }
    end
  end

  # GET /admin/site_menus/:id/live_content
  def live_content
    @site_menu = SiteMenu.find(params[:id])

    respond_to do |format|
      format.html {
        render(
          :layout => true,
          :locals => { :live_items => @site_menu.live_items }
        )
      } # live_content.html.erb
      format.js {
        render(
          :file => '/admin/site_menus/live_content.html.erb',
          :layout => false,
          :locals => { :live_items => @site_menu.live_items }
        )
      }
    end
  end

  # POST /admin/site_menus/:id/order
  def order
    @site_menu = SiteMenu.find(params[:id])
    @site_menu.items.each do |item|
      item.position = params["site_menu_#{@site_menu.id}"].index(item.id.to_s) + 1
      item.save
    end
    render :nothing => true
  end

end
