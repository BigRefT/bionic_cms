class Profile < ActiveRecord::Base
  has_one :user
  has_many :histories, :order => 'created_at DESC, id DESC'
  
  acts_as_audited :protect => false, :except => [:remember_token, :delta, :updated_by]
  
  before_save :encrypt_remember_token
  after_save :save_user
  
  # here to get fieldwithErrors around the combined sign up page
  attr_accessor :password, :password_confirmation, :login

  validates_confirmation_of :email, :if => :new_record?
  validates_presence_of :email, :first_name, :last_name
  validates_presence_of :email_confirmation, :if => :new_record?
  validates_length_of :email, :within => 5..100
  validates_format_of :email, :with => Bionic::EmailValidation
  validates_uniqueness_of :email, :case_sensitive => false, :scope => :site_id, :message => "is in use for an existing account. Login to manage your account."
  validates_associated :user, :message => "account not created"

  acts_as_site_member({ :include_null_site_records => true,
                        :allow_null_site_id => true })
  
  attr_accessible :email, :first_name, :last_name, :email_confirmation
  
  named_scope :by_cookie_token, lambda { |token| { :conditions => ["remember_token = ? and remember_token is not null", token] } }

  class << self
    def find_id_by_cookie_token(token)
      return nil if token.empty_or_nil?
      profiles = Profile.by_cookie_token(token)
      profiles.empty_or_nil? ? nil : profiles.first.id
    end

    def form_for_find(id, profile_id)
      Profile.find(:first, :conditions => ["id = ?", profile_id])
    end
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  alias :name :full_name

  def to_label
    "#{email} (#{full_name})"
  end
  
  def cookie_token
    rvalue = self.remember_token
    if rvalue.empty_or_nil?
      rvalue = encrypt_remember_token
      save(false)
    end
    rvalue
  end
  
  def has_account?
    self.user.not_nil?
  end
  
  private
  
  def encrypt_remember_token
    return unless self.remember_token.empty_or_nil?
    self.remember_token = Digest::SHA1.hexdigest("--#{self.id}--#{self.email}--")
  end
  
  def save_user
    if self.user && self.email_changed? && self.email_was == self.user.login
      self.user.login = self.email
    end
    self.user.save if self.user
  end
end
