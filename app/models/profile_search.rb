class ProfileSearch < ActiveRecord::BaseWithoutTable
  
  column :phrase, :string, ""
  column :page, :integer, 1
  column :per_page, :integer, 25

  def self.per_page_select_options
    [["25", "25"], ["50", "50"], ["100", "100"], ["250", "250"], ["500", "500"], ["1000", "1000"]]
  end

  def profiles
    if Site.current_site_id.nil?
      return Profile.paginate(:all, :page => page, :per_page => per_page, :order => :email)
    end

    if phrase.empty_or_nil?
      Profile.search(
        :with => with,
        :order => order,
        :page => page,
        :per_page => per_page
      )
    else
      if phrase =~ /^user_group:/
        Profile.search(
          :conditions => { :user_group_names => "#{parse_user_group}" },
          :with => with,
          :order => order,
          :page => page
        )
      else
        Profile.search(
          "*#{phrase}*",
          :with => with,
          :order => order,
          :page => page,
          :per_page => per_page
        )
      end
    end
  end

  private

  def with
    { :site_id => Site.current_site_id }
  end

  def order
    :email
  end

  def parse_user_group
    user_group = phrase.split(":")[1]
    user_group.strip!
    user_group
  end

end