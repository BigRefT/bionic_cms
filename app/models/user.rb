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
  validates_length_of       :login,    :within => 3..60
  validates_uniqueness_of   :login, :case_sensitive => false, :scope => :site_id

  before_save :prepare_for_save

  acts_as_audited :protect => false, :except => [:last_login_at, :updated_by, :crypted_password, :salt]

  attr_accessible :login, :password, :password_confirmation

  acts_as_site_member({ :include_null_site_records => true,
                        :allow_null_site_id => true })
  
  class << self
    # Authenticates a user by their login name and unencrypted password.
    # Returns the user or nil.
    def authenticate(login, password)
      u = find :first, :conditions => ['lower(login) = lower(?)', login] # need to get the salt
     (u && u.authenticated?(password) && !u.disabled? && u.valid_for_current_site?) ? u : nil
    end

    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end

    def form_for_find(id, profile_id)
      User.find(:first, :conditions => ["id = ? and profile_id = ?", id, profile_id])
    end
  end

  def auditable_name
    self.login
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def valid_for_current_site?
    self.site_id == Site.current_site_id || self.site_id.nil?
  end
  
  protected
      
  def prepare_for_save
    encrypt_password
  end

  def encrypt_password
    return if password.blank?
    if new_record?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") 
    end
    self.crypted_password = encrypt(password)
  end

  def password_required?
    (crypted_password.blank? || password.not_blank?)
  end
end