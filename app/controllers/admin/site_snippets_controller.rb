class Admin::SiteSnippetsController < ApplicationController
  # GET /admin/site_snippets
  def index
    if session[:site_snippet_search].not_nil? && params[:search].nil?
      params[:search] = session[:site_snippet_search]
    end

    if params[:search]
      session[:site_snippet_search] = params[:search]
      @site_snippets = SiteSnippet.search(params[:search], params[:page])
    else
      @site_snippets = SiteSnippet.paginate(:all, :page => params[:page], :order => 'name')
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/site_snippets/1
  def show
    @site_snippet = SiteSnippet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/site_snippets/new
  def new
    @site_snippet = SiteSnippet.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/site_snippets/1/edit
  def edit
    @site_snippet = SiteSnippet.find(params[:id])
  end

  # POST /admin/site_snippets
  def create
    @site_snippet = SiteSnippet.new(params[:site_snippet])

    respond_to do |format|
      if @site_snippet.save
        flash[:notice] = 'SiteSnippet was successfully created.'
        format.html { redirect_to(admin_site_snippet_url(@site_snippet)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/site_snippets/1
  def update
    @site_snippet = SiteSnippet.find(params[:id])

    respond_to do |format|
      if @site_snippet.update_attributes(params[:site_snippet])
        flash[:notice] = 'SiteSnippet was successfully updated.'
        format.html { redirect_to(admin_site_snippet_url(@site_snippet)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/site_snippets/1
  def destroy
    @site_snippet = SiteSnippet.find(params[:id])
    @site_snippet.destroy

    respond_to do |format|
      flash[:warning] = "SiteSnippet was successfully deleted."
      format.html { redirect_to(admin_site_snippets_url) }
    end
  end

  # POST /admin/site_snippets/:id/start_draft
  def start_draft
    toggle_draft_mode(:current, 'Could not enter in to Draft Mode!')
  end
  
  # POST /admin/site_snippets/:id/publish_draft
  def publish_draft
    toggle_draft_mode
  end

  # GET /admin/site_snippets/:id/live_content
  def live_content
    @site_snippet = SiteSnippet.find(params[:id])

    respond_to do |format|
      format.html {
        render :text => @site_snippet.live.content, :layout => false, :content_type => "text/plain"
      }
      format.js { render :layout => false } # live_content.js.erb
    end
  end

  private

  def toggle_draft_mode(version = nil, error_message = 'Could not make live!')
    @site_snippet = SiteSnippet.find(params[:id])

    SiteSnippet.without_auditing do
      @site_snippet.live_version = version == :current ? @site_snippet.current_version : version
      if @site_snippet.save
        flash[:notice] = 'SiteSnippet was successfully updated.'
      else
        flash[:error] = error_message
      end
    end

    respond_to do |format|
      format.html { redirect_to(admin_site_snippet_url(@site_snippet)) }
    end
  end

end
