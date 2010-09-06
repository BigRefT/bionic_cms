class Object
  def self.descendants
    subclasses_of(self)
  end
  
  def not_nil?
    !nil?
  end
  
  def not_blank?
    !blank?
  end

  def empty_or_nil?
    return true if nil?
    return true if respond_to?(:blank?) && blank?
    return true if respond_to?(:length) && length == 0
    return true if respond_to?(:size) && size == 0
    return true if respond_to?(:empty?) && empty?
    return false
  end
  
  def to_boolean
    if self.empty_or_nil?
      nil
    else
      [true, 1, '1', 't', 'T', 'true', 'TRUE', 'True'].include?(self)
    end
  end
end