class CreateAdminUser < ActiveRecord::Migration
  def self.up
		# TODO: Change the password
    u = User.create(:password => "password", 
                    :password_confirmation => "password", 
                    :first_name => "Administrator",
                    :last_name => "User",
                    :email => "administrator@a.com",
                    :login => "admin")

		Lockdown::System.make_user_administrator(u)
  end
	 
  def self.down
    #Nothing to see here...
	end
end
