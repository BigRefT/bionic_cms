module Lockdown
  class System
    extend Lockdown::Rules

    def self.configure(&block)
      set_defaults 

      # Lockdown::Rules defines the methods that are used inside block
      instance_eval(&block)

      # Lockdown::Rules defines process_rules
      process_rules

      Lockdown::Database.sync_with_db unless skip_sync?

      @initialized = true if Lockdown.caching?
    end

    def self.initialized?
      @initialized
    end

    def self.fetch(key)
      (@options||={})[key]
    end

    def self.call(object, system_option)
      method = fetch(system_option)
      if method.is_a?(Symbol) && object.respond_to?(method)
        object.send(method) 
      end
    end

    protected 

    def self.paths_for(str_sym, *methods)
      str_sym = str_sym.to_s if str_sym.is_a?(Symbol)
      if methods.empty?
        klass = Lockdown.fetch_controller_class(str_sym)
        methods = available_actions(klass) 
      end
      path_str = str_sym.gsub("__","\/") 
        
      subdir = Lockdown::System.fetch(:subdirectory)
      path_str = "#{subdir}/#{path_str}" if subdir

      controller_actions = methods.flatten.collect{|m| m.to_s}

      paths = controller_actions.collect{|meth| "#{path_str}/#{meth.to_s}" }

      if controller_actions.include?("index")
        paths += [path_str]
      end

      paths
    end
 end # System class
end # Lockdown
