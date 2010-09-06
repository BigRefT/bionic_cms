class SiteMenu < ActiveRecord::Base
  before_save :update_handle
  has_many :site_menu_items, :dependent => :destroy, :order => 'position, id'

  validates_presence_of :name

  acts_as_audited :protect => false
  
  attr_accessible :name

  acts_as_site_member

  def items
    self.site_menu_items.reject { |site_menu_item| site_menu_item.draft_delete? }
  end
  
  def live_items
    return self.items unless self.in_draft_mode?
    item_revisions = []
    site_menu_items.each do |site_item|
      next if site_item.draft_new?
      item_revisions << site_item.live
    end
    item_revisions = item_revisions.sort_by { |site_menu| site_menu.id }
    item_revisions = item_revisions.sort_by { |site_menu| site_menu.position }
    item_revisions
  end

  def active_item_revisions(site_in_draft_mode = nil)
    site_in_draft_mode.empty_or_nil? || site_in_draft_mode == false ? self.live_items : self.items
  end

  def begin_draft_mode!
    return false if self.in_draft_mode?
    begin
      transaction do
        # site menu
        self.in_draft_mode = true
        SiteMenu.without_auditing do
          raise ActiveRecord::Rollback unless self.save
        end
        
        # site menu items
        self.items.each do |site_item|
          site_item.live_version = site_item.current_version
          SiteMenuItem.without_auditing do
            raise ActiveRecord::Rollback unless site_item.save
          end
        end
      end
    rescue Exception => e
      return false
    end
    true
  end

  def end_draft_mode!
    return false unless self.in_draft_mode?
    begin
      transaction do
        # site menu
        self.in_draft_mode = false
        SiteMenu.without_auditing do
          raise ActiveRecord::Rollback unless self.save
        end
        
        # site menu items
        self.site_menu_items.each do |site_item|
          if site_item.draft_delete?
            site_item.destroy
          else
            site_item.live_version = nil
            site_item.draft_delete = false
            site_item.draft_new = false
            SiteMenuItem.without_auditing do
              raise ActiveRecord::Rollback unless site_item.save
            end
          end
        end
      end
    rescue Exception => e
      return false
    end
    true
  end

private

  def update_handle
    self.handle = self.name.to_handle
  end

end
