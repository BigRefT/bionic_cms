class UserDrop < Liquid::Drop
  def initialize(user, profile)
    @user = user
    @profile = profile
  end

  def is_known
    profile.not_nil?
  end
  alias :known? :is_known

  def not_known?
    !known?
  end

  def is_logged_in
    profile.not_nil?
  end
  alias :logged_in? :is_logged_in

  def not_logged_in?
    !logged_in?
  end
  
  def has_account?
    return false if profile.nil?
    profile.user.not_nil?
  end
  
  def has_no_account?
    !has_account?
  end
  
  def user_group
    return 'Public Access' if user.nil?
    return 'Registered Users' if user.user_groups.length == 0
    return user.user_groups.first.name
  end
  
  def user_groups
    return ['Public Access'] if user.nil?
    return ['Registered Users', 'Public Access'] if user.user_groups.length == 0
    return (user.user_groups.map(&:name) + ['Registered Users', 'Public Access'])
  end
  
  def name
    profile_attribute :name
  end
  
  def first_name
    profile_attribute :first_name
  end

  def last_name
    profile_attribute :last_name
  end
  
  def email
    profile_attribute :email
  end
  
  def login
    user_attribute :login
  end
  
  def id
    user_attribute :id
  end
  
  def profile_id
    profile_attribute :id
  end
  
  private
  
  def profile_attribute(attribute)
    return nil if not_logged_in? && ![:email, :first_name].include?(attribute)
    return nil if user.nil? && profile.nil?
    return profile.send(attribute)
  end
  
  def user_attribute(attribute)
    return nil if not_logged_in?
    return nil if user.nil? && profile.nil?
    return user.send(attribute)
  end

  def profile
    @profile
  end

  def user
    @user
  end

end