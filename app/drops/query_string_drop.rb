class QueryStringDrop < Liquid::Drop
  def initialize(query_string)
    @query_string = query_string
    @params = []
    @query_string.each do |key, value|
      unescaped_value = value.empty_or_nil? ? nil : CGI::unescape(value)
      @params << UrlParamDrop.new(key, unescaped_value)
    end
  end
  
  def params
    @params
  end
  
  def before_method(param)
    CGI::unescape(@query_string[param.to_sym]) if @query_string[param.to_sym]
  end
end

class UrlParamDrop < Liquid::Drop
  def initialize(key, value)
    @key = key
    @value = value
  end
  
  def key
    @key.to_s
  end
  
  def value
    @value
  end
end
