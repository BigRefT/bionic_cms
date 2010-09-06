require 'liquid'

ActiveRecord::Base.class_eval do
  def self.validates_proper_liquid_syntax(*attr_names)
    validates_each attr_names do |record, attr, value|
      begin
        Liquid::Template.parse(value)
      rescue Liquid::SyntaxError => e
        record.errors.add(attr, e.to_s)
      end
    end
  end
end

