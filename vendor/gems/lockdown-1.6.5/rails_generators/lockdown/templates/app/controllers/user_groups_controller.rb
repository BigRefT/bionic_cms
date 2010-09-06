class <%= "#{namespace.camelcase}::" unless namespace.blank? %>UserGroupsController < ApplicationController
	before_filter :find_user_group, :only => [:show, :edit, :update, :destroy]
	after_filter :update_permissions, :only => [:create, :update]

  # GET /user_groups
  # GET /user_groups.xml
  def index
    @user_groups = UserGroup.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_groups }
    end
  end

  # GET /user_groups/1
  # GET /user_groups/1.xml
  def show
		@all_permissions = Lockdown::System.permissions_assignable_for_user(current_user)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_group }
    end
  end

  # GET /user_groups/new
  # GET /user_groups/new.xml
  def new
    @user_group = UserGroup.new
		@all_permissions = Lockdown::System.permissions_assignable_for_user(current_user)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_group }
    end
  end

  # GET /user_groups/1/edit
  def edit
		@all_permissions = Lockdown::System.permissions_assignable_for_user(current_user)
  end

  # POST /user_groups
  # POST /user_groups.xml
  def create
    @user_group = UserGroup.new(params[:user_group])

    respond_to do |format|
      if @user_group.save
        flash[:notice] = 'UserGroup was successfully created.'
        <% if namespace %>
          format.html { redirect_to(<%= namespace %>_user_group_path(@user_group)) }
        <% else %>
          format.html { redirect_to(user_group_path(@user_group)) }
        <% end %>
        format.xml  { render :xml => @user_group, :status => :created, :location => @user_group }
      else
				@all_permissions = Lockdown::System.permissions_assignable_for_user(current_user)
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_groups/1
  # PUT /user_groups/1.xml
  def update
    respond_to do |format|
      if @user_group.update_attributes(params[:user_group])
        flash[:notice] = 'UserGroup was successfully updated.'
        <% if namespace %>
          format.html { redirect_to(<%= namespace %>_user_group_path(@user_group)) }
        <% else %>
          format.html { redirect_to(user_group_path(@user_group)) }
        <% end %>
        format.xml  { head :ok }
      else
				@all_permissions = Lockdown::System.permissions_assignable_for_user(current_user)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_groups/1
  # DELETE /user_groups/1.xml
  def destroy
    @user_group.destroy

    respond_to do |format|
      format.html { redirect_to(<%= namespace.blank? ? 'user_groups_path' : "#{namespace}_user_groups_path" %>) }
      format.xml  { head :ok }
    end
  end

	private

	def find_user_group
    @user_group = UserGroup.find(params[:id])
    if <%= action_name %> != "show" && Lockdown::System.has_user_group?(@user_group)
      raise SecurityError,"Invalid attempt to modify user group."
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
end
