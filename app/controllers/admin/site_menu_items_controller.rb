class Admin::SiteMenuItemsController < ApplicationController
  
  # GET /admin/site_menus/:site_menu_id/links/new
  def new
    @site_menu_item = SiteMenuItem.new
    @site_menu_item.site_menu_id = params[:site_menu_id]
    site_menus

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /admin/site_menus/:site_menu_id/links
  def create
    @site_menu_item = SiteMenuItem.new(params[:site_menu_item])

    respond_to do |format|
      if @site_menu_item.save
        flash[:notice] = "SiteMenuItem was successfully created."
        format.html { redirect_to(new_admin_site_menu_site_menu_item_url(@site_menu_item.site_menu_id)) }
      else
        site_menus
        format.html { render :action => "new" }
      end
    end
  end

  # GET /admin/site_menus/:site_menu_id/links/:id/edit
  def edit
    @site_menu_item = SiteMenuItem.find(params[:id])
    site_menus
  end

  # POST /admin/site_menus/:site_menu_id/links/:id
  def update
    @site_menu_item = SiteMenuItem.find(params[:id])

    respond_to do |format|
      if @site_menu_item.update_attributes(params[:site_menu_item])
        flash[:notice] = "SiteMenuItem was successfully updated."
        format.html { redirect_to(admin_site_menus_url) }
      else
        site_menus
        format.html { render :action => "new" }
      end
    end
  end

  # DELETE /admin/site_menus/:site_menu_id/links/:id
  def destroy
    @site_menu_item = SiteMenuItem.find(params[:id])
    @site_menu_item.flag_or_destroy!

    respond_to do |format|
      flash[:warning] = "SiteMenuItem was successfully deleted."
      format.html { redirect_to(admin_site_menus_url) }
    end
  end

  private
  
  def site_menus
    @site_menus = SiteMenu.find(:all, :order => "name", :conditions => ["id <> ?", @site_menu_item.site_menu_id])
  end

end
