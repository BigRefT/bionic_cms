class ThemePage < Page
  validate :valid_class_name

  acts_as_site_member

  class << self
    def is_descendant_class_name?(klass_name)
      (ThemePage.descendants.map(&:name) + [nil, "", "ThemePage"]).include?(klass_name)
    end

    def load_subclasses
      ([RAILS_ROOT, BIONIC_ROOT] + Bionic::Extension.descendants.map(&:root)).each do |path|
        Dir["#{path}/app/models/*_theme_page.rb"].each do |page|
          $1.camelize.constantize if page =~ %r{/([^/]+)\.rb}
        end
      end
    end

    def page_types_for_select
      ThemePage.descendants.map { |p| [p.name.to_readable, p.name] }
    end
  end

  def valid_class_name
    unless ThemePage.is_descendant_class_name?(self.class_name)
      errors.add :class_name, "must be set to a valid descendant of ThemePage"
    end
  end
  
  def theme_page?
    true
  end

  def allow_multiple?
    false
  end

end