Liquid::Strainer.class_eval <<-EOV
  def self.filters
    rvalue = []
    @@filters.each do |name, filter|
      rvalue << filter
    end
    rvalue
  end
EOV
