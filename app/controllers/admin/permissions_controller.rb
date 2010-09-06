class Admin::PermissionsController < ApplicationController
  # GET /admin_permissions
  # GET /admin_permissions.xml
  def index
    if params[:search]
      @permissions = Permission.search(params[:search], params[:page])
    else
      @permissions = Permission.paginate(:all, :page => params[:page], :order => 'name')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @permissions }
    end
  end
end
