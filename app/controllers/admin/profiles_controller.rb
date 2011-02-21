class Admin::ProfilesController < ApplicationController
  before_filter :find_profile, :only => [:edit, :update, :enable, :disable]

  # GET /admin/profiles
  def index
    load_saved_profile_search
    if params[:clear]
      clear_profile_search
    end
    if @profile_search.nil?
      create_new_profile_search
    end
    @profile_search.page = params[:page] || 1
    save_profile_search
    search_profiles

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/profiles/new
  def new
    @profile = Profile.new
    @profile.build_user
    @user_groups_for_user = find_user_groups_for_user
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/profiles/:id/edit
  def edit
    @user_groups_for_user = find_user_groups_for_user
    @histories = @profile.histories.find(:all, :limit => 10)
  end

  # POST /admin/profiles
  def create
    @profile = Profile.new(params[:profile])
    @profile.build_user(params[:user])
    @profile.histories.build(:message => "Profile Created: by Admin")

    respond_to do |format|
      if @profile.save
        update_user_groups
        flash[:notice] = 'Profile was successfully created.'
        format.html { redirect_to(admin_profiles_url) }
      else
        @user_groups_for_user = find_user_groups_for_user
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/profiles/:id
  def update
    respond_to do |format|
      @profile.user.attributes = params[:user] if params[:user]
      @profile.attributes = params[:profile]
      if @profile.save
        update_user_groups
        flash[:notice] = 'Profile was successfully updated.'
        format.html { redirect_to(admin_profiles_url) }
      else
        @user_groups_for_user = find_user_groups_for_user
        @histories = @profile.histories.find(:all, :limit => 10)
        format.html { render :action => "edit" }
      end
    end
  end

  def enable
    respond_to do |format|
      @profile.user.disabled = false
      if @profile.user.save
        @profile.histories.create(:message => "Enabled")
        flash[:notice] = 'Profile was successfully enabled.'
        format.html { redirect_to(admin_profiles_url) }
      else
        format.html { render :action => "index" }
      end
    end
  end

  def disable
    respond_to do |format|
      @profile.user.disabled = true
      if @profile.user.save
        @profile.histories.create(:message => "Disabled")
        flash[:notice] = 'Profile was successfully disabled.'
        format.html { redirect_to(admin_profiles_url) }
      else
        format.html { render :action => "index" }
      end
    end
  end

  private

  def update_user_groups
    return if @profile.user.nil? || @profile.user.id == current_user_id
    new_ug_ids = params.collect{|p| p[0].split("_")[1].to_i if p[0] =~ /^ug_/}.compact
    # Removed previously associated user_groups if not checked this time.
    #
    @profile.user.user_groups.dup.each do |g|
      unless new_ug_ids.include?(g.id)
        @profile.user.user_groups.delete(g)
        @profile.histories.create(:message => "Removed from #{g.name} user group")
      end
    end
    # Add in the new permissions
    #
    new_ug_ids.each do |id|
      next if @profile.user.user_group_ids.include?(id)
      ug = UserGroup.find(id)
      @profile.user.user_groups << ug
      @profile.histories.create(:message => "Added to #{ug.name} user group")
    end
  end

  def find_user_groups_for_user
    if current_user_is_admin?
      UserGroup.find(:all)
    elsif current_user_access_in_group?(:site_administrators)
      UserGroup.all_for_current_site
    else
      Lockdown::System.user_groups_assignable_for_user(current_user)
    end
  end

  def find_profile
    @profile = Profile.find(params[:id])
  end

  def load_saved_profile_search
    if session[:profile_search].not_nil? && params[:profile_search].nil?
      @profile_search = session[:profile_search]
    end
  end

  def clear_profile_search
    @profile_search = nil
    params[:profile_search] = nil
  end

  def create_new_profile_search
    @profile_search = ProfileSearch.new(new_profile_search_params)
  end

  def new_profile_search_params
    params[:profile_search]
  end

  def save_profile_search
    session[:profile_search] = @profile_search
  end

  def search_profiles
    @profiles = @profile_search.profiles
  end
end
