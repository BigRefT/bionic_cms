module Bionic
  module Session
    protected

    def bionic_reset_session
      reset_session
      cookies.delete :user_profile_id
    end

    def set_session_user(user)
      add_lockdown_session_values(user)
      if user.nil?
        nil_lockdown_values
        check_profile_cookie
        return
      end
      set_session_profile(user.profile)
    end

    def set_session_profile(profile)
      return if profile.nil?
      session[:user_profile_id] = profile.id

      # save profile id
      cookies[:user_profile_id] = {
        :value => profile.cookie_token,
        :expires => 1095.days.from_now,
        :path => "/"
      }
    end

    def user_known?
      current_profile_id.to_i > 0
    end

    #
    # Does the current user have access to at least one user group
    # that is not public_access or registered_user
    #
    def current_user_has_user_group?
      return true if current_user_is_admin?
      session[:access_rights].each do |perm|
        return true if !Lockdown::System.permission_assigned_automatically?(perm)
      end
      false
    end

    def current_user_group_label
      return "Admin" if current_user_is_admin?
      return "User"
    end

    def current_user
      return current_user_id.to_i > 0 ? User.find(current_user_id, :include => [:profile, :user_groups]) : nil
    end

    def current_profile_id
      return session[:user_profile_id] || -1
    end

    def current_profile
      return current_profile_id.to_i > 0 ? Profile.find(current_profile_id) : nil
    end

    def request_host
      request.host || "emptydomain"
    end

    def current_user_can_access_page?(page)
      return false if page.empty_or_nil?
      user = current_user
      # admins have access to everything
      return true if current_user_is_admin?
      # everyone has access to public
      return true if page.always_public?
      return true if page.allow_public_access?
      # assume public if no user groups and not registered restricted
      return true if page.user_groups.length == 0 && !page.allow_registered_users?
      # allow if logged in and registered restricted
      return true if user && page.allow_registered_users?
      # deny at this point because you have to be logged in to access page
      return false unless logged_in?
      # deny if current user doesn't belong to any user groups
      return false if user.user_groups.length == 0
      # now loop trough the user groups and see if the current user belongs to one
      page.user_groups.each { |grp| return true if user.user_group_ids.include?(grp.id) }
      # retrun false if no matches
      return false
    end
  end # Session module
end # Bionic module

ActionController::Base.class_eval do
  include Bionic::Session
end

ActionController::Base.class_eval do 
  # lockdown session methods
  helper_method :logged_in?, :current_user_is_admin?, :current_user_id
  # bionic session methods
  helper_method :user_known?,
    :current_user,
    :current_profile,
    :current_profile_id,
    :current_user_has_user_group?,
    :current_user_group_label,
    :request_host,
    :current_user_can_access_page?
end