class CustomNotifier < ActiveRecord::Base

  acts_as_site_member
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :site_id
  attr_accessible :name
  before_validation :format_name
  
  named_scope :with_notifier_type_and_name, lambda { |notifier_type, name| { :conditions => { :name => name, :notifier_type => notifier_type } } }

  private
  
  def format_name
    self.name = self.name.to_handle.camelize unless self.name.empty_or_nil?
  end
  
  def validate
    self.errors.add(:name, "can't be the same as a system notifier.") if Bionic::EmailSettings.instance.notifier_by_name(self.name)
  end
  
end
