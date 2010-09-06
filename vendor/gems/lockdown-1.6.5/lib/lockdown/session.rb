module Lockdown
  module Session

    protected

    def add_lockdown_session_values(user = nil)
      user ||= current_user

      if user
        session[:access_rights] = Lockdown::System.access_rights_for_user(user)
        session[:current_user_id] = user.id
      else
        session[:access_rights] = Lockdown::System.public_access
      end
    end

    def logged_in?
      current_user_id.to_i > 0
    end

    def current_user_id
      session[:current_user_id]
    end

    def current_user_is_admin?
      session[:access_rights] == :all
    end

    def current_user_access_in_group?(grp)
      return true if current_user_is_admin?
        Lockdown::System.user_groups[grp].each do |perm|
          return true if access_in_perm?(perm)
        end
      false
    end

    def access_in_perm?(perm)
      if Lockdown::System.permissions[perm]
        Lockdown::System.permissions[perm].each do |ar|
          return true if session_access_rights_include?(ar)
        end 
      end
      false
    end

    def session_access_rights_include?(str)
      return false unless session[:access_rights]
      session[:access_rights].include?(str)
    end

    def reset_lockdown_session
      [:expiry_time, :current_user_id, :access_rights].each do |val|
        session[val] = nil if session[val]
      end
    end 

    alias_method :nil_lockdown_values, :reset_lockdown_session
  end # Session
end # Lockdown
