class Admin::SitePagesController < ApplicationController
  # GET /admin/site_pages
  def index
    @site_pages = SitePage.find_top_pages
    @theme_pages = ThemePage.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def search
    # go back to index if no search text
    if params[:search].blank?
      redirect_to :action => :index
      return
    end
    @site_pages = SitePage.search(params[:search], params[:page])

    respond_to do |format|
      format.html # search.html.erb
    end
  end

  # GET /admin/site_pages/:id
  def show
    @page = Page.find(params[:id])
    show_prep

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/site_pages/new
  def new
    @page = Page.new
    @page.published_at = Time.current
    @page.parent_id = params[:id]
    if params[:theme].not_nil?
      @page.class_name = params[:theme]
    else
      @site_route = SiteRoute.new
    end
    # get inherits
    if @page.parent
      @page.class_name = 'ArticleSitePage' if @page.parent.is_a?(BlogSitePage)
      @page.site_layout_id = @page.parent.site_layout_id
    end

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/site_pages/:id/edit
  def edit
    @page = Page.find(params[:id])
    @user_groups_for_user = UserGroup.all_for_current_site
  end

  # POST /admin/site_pages
  def create
    if params[:site_page][:class_name]
      @page = params[:site_page][:class_name].constantize.new(params[:site_page])
    else
      @page = Page.new(params[:site_page])
    end
    @page.parent_id = params[:site_page][:parent_id]
    @page.class_name = params[:site_page][:class_name]
    if @page.parent
      @page.meta_keywords = @page.parent.meta_keywords if @page.meta_keywords.empty_or_nil?
      @page.meta_description = @page.parent.meta_description if @page.meta_description.empty_or_nil?
      @page.user_groups = @page.parent.user_groups
      @page.allow_registered_users = @page.parent.allow_registered_users
      @page.allow_public_access = @page.parent.allow_public_access
      
      @page.parent.parts.each do |part|
        @page.parts.build(:name => part.name, :content_type => part.content_type, :content => part.name)
      end
    else
      @page.parts.build(:name => "body", :content_type => "plain text", :content => "body")
    end

    respond_to do |format|
      if @page.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to(admin_site_page_url(@page)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/site_pages/:id
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      # class_name is disabled for theme pages so it may not be in the params
      @page.class_name = params[:site_page][:class_name] if params[:site_page][:class_name]
      if @page.update_attributes(params[:site_page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(admin_site_pages_url) }
      else
        @user_groups_for_user = UserGroup.all_for_current_site
        format.html { render :action => "edit" }
      end
    end
  end
  
  # PUT /admin/site_pages/:id/update_parts
  def update_parts
    @page = Page.find(params[:id])

    respond_to do |format|
      if params[:parts]
        flash[:error] = ""
        
        @page.parts.each do |page_part|
          page_part.attributes = params[:parts][page_part.id.to_s]
          unless page_part.valid?
            page_part.errors.full_messages.each { |msg| flash[:error] += "<br />&nbsp;&nbsp;&nbsp;&nbsp;#{msg}" }
          end
        end
        
        if flash[:error].empty_or_nil?
          flash[:error] = nil
          @page.parts.each(&:save)
        else
          flash[:error] = "Invalid syntax in one of the parts." + flash[:error]
          show_prep
          format.html { render :action => :show }
        end
      end
      format.html { redirect_to(admin_site_page_url(@page)) }
    end
  end

  # GET /admin/site_pages/:id/children
  def children
    site_page = Page.find(params[:id])
    level = params[:level] ? params[:level].to_i : 0
    respond_to do |format|
      format.js {
        if site_page.children
          render :partial => 'site_page', :collection => site_page.children.find(:all, :order => "name"), :locals => {:level => level + 1}
        else
          render :text => ""
        end
      }
    end
  end

  # DELETE /admin/site_pages/:id
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      flash[:warning] = "Page was successfully deleted."
      format.html { redirect_to(admin_site_pages_url) }
    end
  end

  def add_site_route
    @page = Page.find(params[:id])
    @page.add_site_route(params[:url_handle]) if params[:url_handle]

    respond_to do |format|
      if @page.save
        flash[:notice] = 'SiteRoute was successfully created.'
        format.html { redirect_to(edit_admin_site_page_url(@page)) }
      else
        flash[:error] = "Site Route invalid."
        format.html { redirect_to(edit_admin_site_page_url(@page)) }
      end
    end
  end

  def update_user_groups
    @page = Page.find(params[:id])
    new_ug_ids = params.collect{|p| p[0].split("_")[1].to_i if p[0] =~ /^ug_/}.compact
    # Removed previously associated user_groups if not checked this time.
    @page.user_groups.dup.each do |g|
      @page.user_groups.delete(g) unless new_ug_ids.include?(g.id)
    end
    # Add in the new permissions
    new_ug_ids.each do |id|
      next if @page.user_group_ids.include?(id)
      @page.user_groups << UserGroup.find(id)
    end

    @page.allow_public_access = params[:allow_public_access] ? true : false
    @page.allow_registered_users = params[:allow_registered_users] ? true : false

    respond_to do |format|
      if @page.save
        @page.apply_access_rights_to_children if params[:recursive]
        flash[:notice] = 'User Groups updated for Site Page.'
        format.html { redirect_to(edit_admin_site_page_url(@page)) }
      else
        flash[:error] = "User Groups invalid."
        format.html { redirect_to(edit_admin_site_page_url(@page)) }
      end
    end
  end
  
  private
  
  def show_prep
    @user_groups_for_user = UserGroup.all_for_current_site
  end
end