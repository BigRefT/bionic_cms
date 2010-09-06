require 'digest/sha1'
class User < ActiveRecord::Base
  has_and_belongs_to_many :user_groups
  belongs_to :profile
  
  # Virtual attributes
  attr_accessor :password

  validates_presence_of     :login
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login, :case_sensitive => false
  
	before_save :encrypt_password
	before_save :save_profile

  attr_accessible :login, :password, :password_confirmation, 
                  :first_name, :last_name, :email
  
  # Authenticates a user by their login name and unencrypted password.  
  # Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ?', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end
  
  def full_name
    first_name + " " + last_name
  end

  # Profile information
  def first_name
    user_profile.first_name
  end
  
  def first_name=(string)
    user_profile.first_name = string
  end
  
  def last_name
    user_profile.last_name
  end
  
  def last_name=(string)
    user_profile.last_name = string
  end
  
  def email
    user_profile.email
  end
  
  def email=(string)
    user_profile.email = string
  end

  def user_profile
    self.profile || self.profile = Profile.new
  end
  
  protected
      
  def encrypt_password
    return if password.blank?
    if new_record?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") 
    end
    self.crypted_password = encrypt(password)
  end

  def save_profile
    profile.save
  end
  
  def password_required?
    (crypted_password.blank? || !password.blank?)
  end
    
end
