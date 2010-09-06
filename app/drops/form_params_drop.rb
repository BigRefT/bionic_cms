class FormParamsDrop < Liquid::Drop
  def initialize(form_params)
    @form_params = form_params
    @params = []
    @form_params.each do |key, value|
      @params << FormParamDrop.new(key, value)
    end
  end
  
  def params
    @params
  end
  
  def before_method(param)
    @form_params[param.to_sym] if @form_params[param.to_sym]
  end
end

class FormParamDrop < Liquid::Drop
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
