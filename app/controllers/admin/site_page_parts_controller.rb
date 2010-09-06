class Admin::SitePagePartsController < ApplicationController

  # GET /admin/site_pages/:site_page_id/parts/new
  def new
    @page = Page.find(params[:site_page_id])
    @site_page_part = @page.parts.build

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/site_pages/:site_page_id/parts/:id/edit
  def edit
    @site_page_part = SitePagePart.find(params[:id])
    @page = Page.find(params[:site_page_id])
  end

  # POST /admin/site_pages/:site_page_id/parts
  def create
    @page = Page.find(params[:site_page_id])
    @site_page_part = @page.parts.build(params[:site_page_part])

    respond_to do |format|
      if @site_page_part.save
        flash[:notice] = 'SitePagePart was successfully created.'
        format.html { redirect_to(admin_site_page_url(@page)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/site_pages/:site_page_id/parts/:id
  def update
    @page = Page.find(params[:site_page_id])
    @site_page_part = SitePagePart.find(params[:id])

    respond_to do |format|
      if @site_page_part.update_attributes(params[:site_page_part])
        flash[:notice] = 'SitePagePart was successfully updated.'
        format.html { redirect_to(admin_site_page_url(@page)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/site_pages/:site_page_id/parts/:id
  def destroy
    @site_page_part = SitePagePart.find(params[:id])
    @site_page_part.destroy

    respond_to do |format|
      flash[:warning] = "SitePagePart was successfully deleted."
      format.html { redirect_to(admin_site_page_url(Page.find(params[:site_page_id]))) }
    end
  end

  # POST /admin/site_page_part/:id/start_draft
  def start_draft
    toggle_draft_mode(:current, 'Could not enter in to Draft Mode!')
  end
  
  # POST /admin/site_page_part/:id/publish_draft
  def publish_draft
    toggle_draft_mode
  end

  # POST /admin/site_page_part/:id/live_content
  def live_content
    @site_page_part = SitePagePart.find(params[:id])

    respond_to do |format|
      format.html {
        render :text => @site_page_part.live.content, :layout => false, :content_type => "text/plain"
      }
      format.js { render :layout => false } # live_content.js.erb
    end
  end

  private

  def toggle_draft_mode(version = nil, error_message = 'Could not make live!')
    @site_page_part = SitePagePart.find(params[:id])

    SitePagePart.without_auditing do
      @site_page_part.live_version = version == :current ? @site_page_part.current_version : version
      if @site_page_part.save
        flash[:notice] = "SitePagePart: #{@site_page_part.name} was successfully updated."
      else
        flash[:error] = error_message
      end
    end

    respond_to do |format|
      format.html { redirect_to(admin_site_page_url(Page.find(params[:site_page_id]))) }
    end
  end

end
