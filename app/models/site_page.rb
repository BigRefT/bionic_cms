class SitePage < Page
  validate :valid_class_name
  before_save :format_url_handle

  acts_as_site_member

  class << self
    def is_descendant_class_name?(klass_name)
      (SitePage.descendants.map(&:name) + [nil, "", "SitePage"]).include?(klass_name)
    end

    def load_subclasses
      ([RAILS_ROOT, BIONIC_ROOT] + Bionic::Extension.descendants.map(&:root)).each do |path|
        Dir["#{path}/app/models/*_site_page.rb"].each do |page|
          $1.camelize.constantize if page =~ %r{/([^/]+)\.rb}
        end
      end
    end

    def page_types_for_select
      ([['<normal>', 'SitePage']] + SitePage.descendants.map { |p| [p.name.to_readable, p.name] })
    end
  end

  def valid_class_name
    unless SitePage.is_descendant_class_name?(self.class_name)
      errors.add :class_name, "must be set to a valid descendant of SitePage"
    end
  end
  
  private
  
  def format_url_handle
    if self.new_record?
      if self.url_handle.empty_or_nil?
        formatted_url_handle = self.name.to_url_handle
      else
        formatted_url_handle = self.url_handle.to_url_handle
      end

      if self.parent
        self.url_handle = self.parent.url
        self.url_handle += "/" unless self.url_handle == "/"
        self.url_handle += formatted_url_handle
      else
        self.url_handle = "/"
      end
      
      self.site_routes.build(:url_handle => self.url_handle, :main_route => true)
    end
  end
end