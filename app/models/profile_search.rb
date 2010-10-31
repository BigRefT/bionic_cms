class ProfileSearch < ActiveRecord::BaseWithoutTable
  
  column :phrase, :string, ""
  column :page, :integer, 1
  column :per_page, :integer, 25

  def self.per_page_select_options
    [["25", "25"], ["50", "50"], ["100", "100"], ["250", "250"], ["500", "500"], ["1000", "1000"]]
  end

  def profiles
    Profile.paginate(
      :conditions => conditions,
      :per_page => per_page,
      :order => order,
      :page => page,
      :joins => [:user => :user_groups]
    )
  end

  private

  def conditions
    rvalue = nil
    if Site.current_site_id.not_nil? && !phrase.empty_or_nil?
      if phrase =~ /^user_group:/
        rvalue = { :users => { :user_groups => { :name => parse_user_group }}}
      else
        rvalue = [like_conditions.join(" OR ")]
        like_conditions.length.times do
          rvalue << "%#{phrase}%"
        end
      end
    end
    rvalue
  end

  def order
    :email
  end

  def parse_user_group
    user_group = phrase.split(":")[1]
    user_group.strip
  end

  def like_conditions
    [
      "users.login LIKE ?",
      "profiles.email LIKE ?",
      "profiles.first_name LIKE ?",
      "profiles.last_name LIKE ?"
    ]
  end

end