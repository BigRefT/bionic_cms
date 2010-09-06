class ContactForm < ActiveRecord::BaseWithoutTable

  column :form_name, :string, ""
  column :email, :string, ""
  column :custom_notifier_method, :string, ""
  (1..10).each do |number|
    column "custom_#{number.to_s.to_sym}", :string, ""
  end
  
  validates_presence_of :email
  validates_presence_of :form_name, :message => "not configured. Form improperly created."
  validates_presence_of :custom_notifier_method, :message => "not configured. Form improperly initialized."
  validates_length_of :email, :within => 5..100
  validates_format_of :email, :with => Bionic::EmailValidation
  
  def to_hash
    rvalue = {}
    self.class.columns.each do |column|
      rvalue[column.name] = __send__(column.name)
    end
    rvalue
  end

end