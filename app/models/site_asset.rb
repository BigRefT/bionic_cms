require 'ftools'
class SiteAsset < ActiveRecord::Base
  before_save :rename_file_name, :ensure_display_name, :save_content

  acts_as_audited :protect => false
  
  attr_accessor :content
  attr_accessible :asset_file_name, :content, :asset, :tag_list, :display_name
  
  acts_as_site_member
  acts_as_taggable_on :tags
  has_attached_file :asset,
                    :url => "/:attachment/:current_site_id/:style/:basename.:extension",
                    :path => ":rails_root/public/:attachment/:current_site_id/:style/:basename.:extension",
                    :styles => { :thumb => "32x32>" }
  validates_attachment_presence :asset

  named_scope :by_display_name, lambda { |*order| { :order => "display_name #{order || 'ASC'}" } }
  named_scope :with_display_name, lambda { |display_name| { :conditions => ['display_name = ?', display_name] } }

  class << self
    def per_page
      15
    end

    def search(search, page)
      if search =~ /^tags:/
        tag_list = search.split(":")[1]
        tags = tag_list.split(",")
        tags.each(&:strip!)
        SiteAsset.tagged_with(tags.join(", "), :on => :tags).by_display_name.paginate(:page => page)
      else
        paginate :page => page,
          :conditions => ['(lower(asset_file_name) like lower(?) or lower(display_name) like lower(?))', "%#{search}%", "%#{search}%"],
          :order => 'display_name'
      end
    end
  end

  def editable_type?
    ['text/html', 'text/css', 'text/js', 'application/x-javascript', 'text/plain', 'application/x-js'].include?(asset_content_type)
  end

  before_post_process :image_type?
  def image_type?
    Bionic::ImageContentTypes.include?(asset_content_type)
  end
  
  def compressed_type?
    ['application/zip'].include?(asset_content_type)
  end

  def file_path(style = "original")
    "#{RAILS_ROOT}/public/assets/#{self.site_id}/#{style}/#{self.asset_file_name}"
  end

  def url(style = :original)
    self.asset.url(style)
  end
  
  def file_name
    asset_file_name
  end
  
  def name
    display_name
  end

private 

  def rename_file_name
    if self.asset_file_name_changed?
      old_file_name = self.asset_file_name_was
      old_file_path = "#{RAILS_ROOT}/public/assets/#{self.site_id}/original/#{old_file_name}"
      old_thumb_path = "#{RAILS_ROOT}/public/assets/#{self.site_id}/thumb/#{old_file_name}"
      if File.exists?(old_file_path)
        File.move(old_file_path, self.file_path)
      end
      if File.exists?(old_thumb_path)
        File.move(old_thumb_path, self.file_path("thumb"))
      end
    end
  end

  def save_content
    if self.editable_type? && self.content
      #save content to file
      if File.exists?(self.file_path)
        # deleting instead of just updating because
        #   of the file system reporting incorrect file size.
        # if the amount of content decreases and we just write it back to the old file
        #   then the file size will remain at the bigger size.
        File.delete(self.file_path)
        File.open(self.file_path, "w") { |f| f.write self.content }
        self.asset_file_size = File.size(self.file_path)
      else
        self.errors.add(:content, "unable to update file contents.")
      end
    end
  end
  
  def ensure_display_name
    if self.display_name.nil? || self.display_name.blank?
      self.display_name = self.file_name
    end
  end
end
