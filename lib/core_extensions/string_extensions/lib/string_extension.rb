class String
  def to_handle
    result = self.downcase
    # strip all non word chars that aren't periods
    result.gsub!(/\W/, ' ')
    # replace all white space sections with an underscore
    result.gsub!(/\ +/, '_')
    # trim underscore
    result.gsub!(/(_+)$/, '')
    result.gsub!(/^(_+)/, '')  
    result
  end

  def to_url_handle
    result = self.downcase
    # strip all non word chars that aren't periods
    result.gsub!(/[^\w.-]/, ' ')
    # replace all white space sections with an underscore
    result.gsub!(/\ +/, '_')
    # trim underscore
    result.gsub!(/(_+)$/, '')
    result.gsub!(/^(_+)/, '')  
    result
  end

  def to_readable
    result = self.gsub(/([A-Z])/, ' \1')
    result.strip
  end

  def truncate_url
    result = self.gsub(/\/[\w-]+\//, "/.../")
    result = result.gsub(/\/[\w-]+\//, "/.../")
    result
  end
  
  # rip from ActionView::TextHelper so I can use in models
  def truncate(*args)
    options = args.extract_options!
    unless args.empty?
      options[:length] = args[0] || 30
      options[:omission] = args[1] || "..."
    end
    options.reverse_merge!(:length => 30, :omission => "...")

    l = options[:length] - options[:omission].mb_chars.length
    chars = self.mb_chars
    (chars.length > options[:length] ? chars[0...l] + options[:omission] : self).to_s
  end

  def symbolize
    self.gsub(/[^A-Za-z0-9]+/, "_").gsub(/(^_+|_+$)/, "").underscore.to_sym
  end
  
  def titlecase
    self.gsub(/((?:^|\s)[a-z])/) { $1.upcase }
  end
  
  def to_name(last_part = '')
    self.underscore.gsub('/', ' ').humanize.titlecase.gsub(/\s*#{last_part}$/, '')
  end
end