require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib lockdown]))

class Mikey  
  def method_missing(method, *args)    
    true
  end
end

