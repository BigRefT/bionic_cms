class Admin::SiteAssetsController < ApplicationController
  require 'zip/zip'
  # GET /admin_site_assets
  def index
    if session[:site_asset_search].not_nil? && params[:search].nil?
      params[:search] = session[:site_asset_search]
    end

    if params[:search]
      session[:site_asset_search] = params[:search]
      @site_assets = SiteAsset.search(params[:search], params[:page])
    else
      @site_assets = SiteAsset.paginate(:all, :page => params[:page], :order => 'asset_file_name')
    end
    @site_asset = SiteAsset.new

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin_site_assets/1/edit
  def edit
    @site_asset = SiteAsset.find(params[:id])
    if @site_asset.editable_type?
      text_file = File.new(@site_asset.file_path, "r+")
      if text_file
        @site_asset.content = text_file.sysread(@site_asset.asset_file_size.to_i)
      else
        @site_asset.content = "ERROR! Could not open file."
      end
    end
  end

  # POST /admin/site_assets
  def create
    #see if uploaded file name already exist
    uploaded_file_name = File.basename(params[:site_asset][:asset].original_filename)
    @site_asset = SiteAsset.find_by_asset_file_name(uploaded_file_name)
    if @site_asset
      @site_asset.attributes = params[:site_asset]
    else
      @site_asset = SiteAsset.new(params[:site_asset])
    end

    respond_to do |format|
      if @site_asset.save
        flash[:notice] = "SiteAsset : #{uploaded_file_name} was successfully created."
      end
      format.html { redirect_to(admin_site_assets_url) }
    end
  end

  # PUT /admin/site_assets/1
  def update
    @site_asset = SiteAsset.find(params[:id])

    respond_to do |format|
      if @site_asset.update_attributes(params[:site_asset])
        flash[:notice] = "SiteAsset : #{@site_asset.asset_file_name} was successfully updated."
        format.html { redirect_to(admin_site_assets_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def decompress
    @site_asset = SiteAsset.find(params[:id])
    if !@site_asset.compressed_type?
      flash[:error] = "Can't decompress #{@ste_asset.asset_file_name}."
      redirect_to admin_site_assets_url
    else
      Zip::ZipFile.open(@site_asset.file_path) do |zip_file|
        zip_file.each do |f|
          next unless f.file?
          file_path = File.join("#{RAILS_ROOT}/tmp", f.name)
          File.delete(file_path) if File.exist?(file_path)
          zip_file.extract(f, file_path) unless File.exist?(file_path)
          if File.exist?(file_path)
            new_site_asset = SiteAsset.find_by_asset_file_name(f.name)
            if new_site_asset
              new_site_asset.asset = File.open(file_path)
            else
              new_site_asset = SiteAsset.new(:asset => File.open(file_path), :tag_list => @site_asset.tag_list)
            end
            unless new_site_asset.save
              flash[:error] = 'Decompress failed.'
              new_site_asset.errors.each { |key, value| flash[:error] += "<br/>#{key} - #{value}" }
              redirect_to admin_site_assets_url
              return
            end
            File.delete(file_path)
          end
        end
      end
      flash[:notice] = "SiteAsset : #{@site_asset.asset_file_name} was successfully decompressed."
      redirect_to admin_site_assets_url
    end
  end

  # DELETE /admin_site_assets/1
  def destroy
    @site_asset = SiteAsset.find(params[:id])
    asset_file_name = @site_asset.asset_file_name
    @site_asset.destroy

    respond_to do |format|
      flash[:warning] = "SiteAsset : #{asset_file_name} was successfully deleted."
      format.html { redirect_to(admin_site_assets_url) }
      format.xml  { head :ok }
    end
  end
end
