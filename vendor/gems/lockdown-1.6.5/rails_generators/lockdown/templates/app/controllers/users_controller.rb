class <%= "#{namespace.camelcase}::" unless namespace.blank? %>UsersController < ApplicationController
	before_filter :find_user, :only => [:show, :edit, :update, :destroy]
	after_filter :update_user_groups, :only => [:create, :update]
  # GET /users
  # GET /users.xml
  def index
    @users = User.find :all, :include => [:profile, :user_groups]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user_groups_for_user = Lockdown::System.user_groups_assignable_for_user(current_user)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
		@user = User.new
    @user_groups_for_user = Lockdown::System.user_groups_assignable_for_user(current_user)
		respond_to do |format|
     format.html # new.html.erb
     format.xml  { render :xml => @user }
		end
  end

  # GET /users/1/edit
  def edit
    @user_groups_for_user = Lockdown::System.user_groups_assignable_for_user(current_user)
  end
  
  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

		if @user.save
			flash[:notice] = "Thanks for signing up!"
			redirect_to(<%= namespace.blank? ? 'user_path(@user)' : "#{namespace}_user_path(@user)" %>)
		else
			@user_groups_for_user = Lockdown::System.user_groups_assignable_for_user(current_user)
			flash[:error] = "Please correct the following issues"
			render :action => "new" 
    end
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
		@user.attributes = params[:user]

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully updated.'
          format.html { redirect_to(<%= namespace.blank?  ? 'user_path(@user)' : "#{namespace}_user_path(@user)"%>) }
        format.xml  { head :ok }
      else
        @user_groups_for_user = Lockdown::System.user_groups_assignable_for_user(current_user)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(<%= namespace.blank? ? 'users_path' : "#{namespace}_users_path" %>) }
      format.xml  { head :ok }
    end
  end

	def change_password 
		render :update do |page|
			page.replace_html 'password', :partial => 'password'
		end
	end

	private

	def find_user
		# Skip test if current user is an administrator
		unless current_user_is_admin? 
			# Raise error if id not = current logged in user
			raise SecurityError.new if (current_user_id != params[:id].to_i)
		end
		@user = User.find(params[:id])
		raise SecurityError.new if @user.nil?
	end

	def update_user_groups
		new_ug_ids = params.collect{|p| p[0].split("_")[1].to_i if p[0] =~ /^ug_/}.compact
		# Removed previously associated user_groups if not checked this time.
		#
		@user.user_groups.dup.each do |g|
			@user.user_groups.delete(g) unless new_ug_ids.include?(g.id)
    end
	
		# Add in the new permissions
		#
		new_ug_ids.each do |id|
			next if @user.user_group_ids.include?(id)
			@user.user_groups << UserGroup.find(id)
    end
  end
end
