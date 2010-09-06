class UserGroup < ActiveRecord::Base
  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :users
  has_and_belongs_to_many :pages

  acts_as_site_member({:include_null_site_records => true, :allow_null_site_id => true})
  
  acts_as_audited :protect => false

  validates_presence_of :name

  class << self
    def per_page
      15
    end

    def search(search, page)
      paginate :page => page, :conditions => ['lower(name) like lower(?)', "%#{search}%"], :order => 'name'
    end
    
    def all_for_current_site
      if Site.current_site_id.nil?
        find(:all, :conditions => "site_id is null", :order => 'name')
      else
        find(:all, :conditions => ["site_id = ? or (name <> 'Administrators' and site_id is null)", Site.current_site_id], :order => 'name')
      end
    end
  end

  def all_users
    User.find_by_sql <<-SQL
      select users.* 
      from users, user_groups_users
      where users.id = user_groups_users.user_id 
      and user_groups_users.user_group_id = #{self.id}
    SQL
  end
end
