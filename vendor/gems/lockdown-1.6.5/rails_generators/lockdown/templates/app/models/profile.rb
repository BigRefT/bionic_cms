class Profile < ActiveRecord::Base
  SYSTEM = 1
  
  validates_presence_of :email, :first_name, :last_name
  
  validates_length_of :email, :within => 5..100
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  validates_uniqueness_of :email, :case_sensitive => false
end
