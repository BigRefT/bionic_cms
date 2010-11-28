class << ActiveRecord::Base
  alias_method :orig_count, :count
  def count(*args)
    column, options = *construct_count_options_from_args(*args)
    site_conditions = acts_as_site_conditions
    if options[:conditions] && site_conditions.not_nil?
      site_conditions = " and #{site_conditions}"
      if options[:conditions].is_a? String
        options[:conditions] += site_conditions
      elsif options[:conditions].is_a? Array
        options[:conditions][0] += site_conditions
      end
    else
      options[:conditions] = site_conditions
    end
    orig_count(column, options)
  end

  private
  alias_method :orig_find_every, :find_every
  def find_every(*args)
    site_conditions = acts_as_site_conditions
    find_options = {:conditions => site_conditions } if site_conditions.not_nil?
    with_scope :find => (find_options || {}) do
      orig_find_every(*args)
    end
  end
  
  def acts_as_site_conditions
    site_conditions = nil
    if Site.current_site_id || @return_strict_values
      if Site.current_site_id
        if @use_site_id_in_find_every
          site_conditions = "(#{ActiveRecord::Base.connection.quote_table_name(table_name)}.site_id = #{Site.current_site_id}"
          site_conditions += " or #{ActiveRecord::Base.connection.quote_table_name(table_name)}.site_id is null" if @include_null_site_in_find_every
          site_conditions += ")"
        end
      else
        site_conditions = "(#{ActiveRecord::Base.connection.quote_table_name(table_name)}.site_id is null)" if @use_site_id_in_find_every
      end
    end
    site_conditions
  end

end