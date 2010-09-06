class History < ActiveRecord::Base
  belongs_to :profile
  belongs_to :linked, :polymorphic => true
  
  acts_as_site_member({ :allow_null_site_id => true })
  
  def created_at_long_date
    return "" if self.created_at.nil?
    self.created_at.strftime("%b %d, %Y")
  end
  
  def create_at_time
    return "" if self.created_at.nil?
    self.created_at.strftime("%I:%M%p").downcase
  end

end
