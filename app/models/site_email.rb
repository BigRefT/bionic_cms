class SiteEmail < ActiveRecord::Base
  belongs_to :site_snippet

  acts_as_audited :protect => false

  attr_accessible :notifier_name, :subject, :from, :cc, :misc_data,
                  :bcc, :reply_to, :content_type, :site_snippet_id,
                  :number_of_days_after_to_send, :active

  validates_presence_of :notifier_name, :subject, :from, :content_type, :number_of_days_after_to_send
  validates_numericality_of :number_of_days_after_to_send, :only_integer => true, :greater_than_or_equal_to => 0
  acts_as_site_member

  class << self

    def find_all_active_instant_by_notifier_name(name)
      SiteEmail.find(
        :all,
        :conditions => {
          :notifier_name => name,
          :active => true,
          :number_of_days_after_to_send => 0
        }
      )
    end

    def find_all_active_by_notifier_name(name)
      SiteEmail.find(
        :all,
        :conditions => {
          :notifier_name => name,
          :active => true
        }
      )
    end

    def find_first_by_notifier_name(name)
      SiteEmail.find(:first, :conditions => ["notifier_name = ?", name])
    end
    
    def find_all_by_notifier_name(name)
      SiteEmail.find(
        :all,
        :conditions => { :notifier_name => name },
        :order => :number_of_days_after_to_send
      )
    end

  end
  
  def name
    self.notifier_name.to_readable
  end
  
  def full_name
    "#{name}: #{number_of_days_after_to_send_string}"
  end
  
  def auditable_name
    full_name
  end
  
  def bcc_email_array
    return if bcc.nil?
    bcc.split(',').map(&:strip)
  end

  def cc_email_array
    return if cc.nil?
    cc.split(',').map(&:strip)
  end

  def reply_to_email_array
    return if reply_to.nil?
    reply_to.split(',').map(&:strip)
  end
  
  def number_of_days_after_to_send_string
    if self.number_of_days_after_to_send == 0
      "Instant"
    elsif self.number_of_days_after_to_send == 1
      "1 day"
    else
      "#{self.number_of_days_after_to_send} days"
    end
  end

end
