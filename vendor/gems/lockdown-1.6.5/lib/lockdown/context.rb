module Lockdown
  class Context
    attr_accessor :name, :allowed_methods

    def to_s
      self.class.to_s
    end

    def allows?(method_name)
      @allowed_methods.include?(method_name)
    end
  end

  class RootContext < Context
    def initialize(name)
      @name = name
      @allowed_methods = %w(with_controller and_controller to_model)
    end
  end

  class ControllerContext < Context
    def initialize(name)
      @name = name
      @allowed_methods = %w(with_controller and_controller to_model only_methods except_methods)
    end
  end

  class ModelContext < Context
    def initialize(name)
      @name = name
      @allowed_methods = %w(where)
    end
  end

  class ModelWhereContext < Context
    def initialize(name)
      @name = name
      @allowed_methods = %w(is_in includes equals)
    end
  end
end
