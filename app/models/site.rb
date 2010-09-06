class Site < ActiveRecord::Base
  cattr_accessor :current_site_id, :draft_mode
  has_many :profiles, :dependent => :destroy
  has_many :users, :dependent => :destroy
  has_many :user_groups, :dependent => :destroy

  acts_as_audited :protect => false

  validates_presence_of :name, :domain

  attr_accessible :name, :domain

  class << self
    def current_site
      Site.current_site_id.nil? ? nil : Site.find(Site.current_site_id)
    end

    def find_id_by_domain(domain)
      site = find_by_domain(domain)
      site ? site.id : nil
    end
  end

  def to_label
    self.name
  end
end
