class SessionsController < ApplicationController

# This controller handles the login/logout function of the site.
  def new
    #Stub required for Lockdown to grant access
  end

  def create
    password_authentication(params[:login], params[:password])
  end

  def destroy
		logger.info "resetting session in sessions controller"
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  protected

  def password_authentication(login, password)
    set_session_user(User.authenticate(login, password))
    if logged_in?
      successful_login
    else
      failed_login
    end
  end
  
  def failed_login(message = 'Authentication failed.')
    flash[:error] = message
    redirect_back_or_default login_path
  end
	 
  def successful_login
    flash[:notice] = "Logged in successfully"
    redirect_back_or_default Lockdown::System.fetch(:successful_login_path)
  end
end
