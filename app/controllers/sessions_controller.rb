class SessionsController < ApplicationController
  ssl_allowed :create, :destroy, :new

  # This controller handles the login/logout function of the site.
  layout 'application'
  def new
    @user = User.new
  end

  def create
    password_authentication(params[:user][:login], params[:user][:password])
  end

  def destroy
    logger.info "resetting session in sessions controller"
    bionic_reset_session
    flash[:notice] = "You have been logged out."
    redirect_to "/"
  end

  protected

  def password_authentication(login, password)
    set_session_user(User.authenticate(login, password))
    if logged_in?
      user = current_user
      user.last_login_at = DateTime.now
      user.save_without_auditing
      successful_login
    else
      failed_login
    end
  end
  
  def failed_login(message = 'Login unsuccessful. Please try again.')
    flash[:error] = message
    redirect_to login_path
  end
   
  def successful_login
    flash[:notice] = "Logged in successfully"
    path = if session[:previous_page].empty_or_nil?
      if params[:success_url].empty_or_nil? || params[:success_url].first != "/"
        Lockdown::System.fetch :successful_login_path
      else
        params[:success_url] || "/"
      end
    else
      session[:previous_page]
    end
    redirect_to path
  end
end