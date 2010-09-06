class <%= "#{namespace.camelcase}::" unless namespace.blank? %>PermissionsController < ApplicationController
  # GET /permissions
  # GET /permissions.xml
  def index
    @permissions = Permission.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @permissions }
    end
  end

  # GET /permissions/1
  # GET /permissions/1.xml
  def show
    @permission = Permission.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @permission }
    end
  end
end
