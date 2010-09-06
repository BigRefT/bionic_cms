class Admin::UserGroupsController < ApplicationController
  before_filter :find_user_group, :only => [:edit, :update, :destroy]
  before_filter :all_permissions, :only => [:new, :edit]
  after_filter :update_permissions, :only => [:create, :update]

  # GET /admin_user_groups
  def index
    if params[:search]
      @user_groups = UserGroup.search(params[:search], params[:page])
    else
      @user_groups = UserGroup.paginate(:all, :page => params[:page], :order => 'name')
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin_user_groups/new
  def new
    @user_group = UserGroup.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin_user_groups/1/edit
  def edit
  end

  # POST /admin_user_groups
  def create
    @user_group = UserGroup.new(params[:user_group])

    respond_to do |format|
      if @user_group.save
        flash[:notice] = 'UserGroup was successfully created.'
        format.html { redirect_to(admin_user_groups_url) }
      else
        all_permissions
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin_user_groups/1
  def update
    respond_to do |format|
      if @user_group.update_attributes(params[:user_group])
        flash[:notice] = 'UserGroup was successfully updated.'
        format.html { redirect_to(admin_user_groups_url) }
      else
        all_permissions
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin_user_groups/1
  def destroy
    @user_group.destroy

    respond_to do |format|
      format.html { redirect_to(admin_user_groups_path) }
    end
  end

  private

  def find_user_group
    @user_group = UserGroup.find(params[:id])
    if @user_group.site_id.nil?
      raise SecurityError, "Invalid attempt to modify user group."
    end
  end

  def update_permissions
    new_perm_ids = params.collect{|p| p[0].split("_")[1].to_i if p[0] =~ /^perm_/}.compact
    #
    # Removed previously associated permissions if not checked this time.
    #
    @user_group.permissions.dup.each do |p|
      @user_group.permissions.delete(p) unless new_perm_ids.include?(p.id)
    end

    # 
    # Add in the new permissions
    #
    new_perm_ids.each do |id|
      next if @user_group.permission_ids.include?(id)
      @user_group.permissions << Permission.find(id)
    end
  end

  def all_permissions
    @all_permissions = Lockdown::System.permissions_assignable_for_user(current_user).sort_by { |permission| permission.name }
  end
end