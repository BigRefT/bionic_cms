class CustomerController < ApplicationController
  include Bionic::ModelHelpers
  layout 'application'

  def ssl_required?
    true
  end

  def update_user
    if params[:id].to_i == current_user_id
      update_model("User")
    else
      flash[:error] = "Invalid user id. Update failed."
      show_failure(nil)
    end
  end
  
  def update_profile
    if params[:id].to_i == current_profile_id.to_i
      update_model("Profile")
    else
      flash[:error] = "Invalid profile id. Update failed."
      show_failure(nil)
    end
  end
end
