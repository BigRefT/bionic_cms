require 'active_support'

module Lockdown
  module Helper
    def class_name_from_file(str)
      str.split(".")[0].split("/").collect{|s| camelize(s) }.join("::")
    end

    # If str_sym is a Symbol (:users), return "Users"
    # If str_sym is a String ("Users"), return :users
    def convert_reference_name(str_sym)
      if str_sym.is_a?(Symbol)
        titleize(str_sym)
      else
       str_sym.underscore.tr(' ','_').to_sym
      end
    end

    def user_group_class
      eval(user_group_model_string)
    end

    def user_groups_hbtm_reference
      user_group_model_string.underscore.pluralize.to_sym
    end

    def user_group_id_reference
      user_group_model_string.underscore + "_id"
    end

    def user_class
      eval(user_model_string)
    end

    def users_hbtm_reference
      user_model_string.underscore.pluralize.to_sym
    end

    def user_id_reference
      user_model_string.underscore + "_id"
    end

    def user_group_model_string
      Lockdown.system.fetch(:user_group_model) || "UserGroup"
    end
    
    def user_model_string
      Lockdown.system.fetch(:user_model) || "User"
    end
    
    def get_string(value)
      if value.respond_to?(:name)
        string_name(value.name)
      else
        string_name(value)
      end
    end

    def get_symbol(value)
      if value.respond_to?(:name)
        symbol_name(value.name)
      elsif value.is_a?(String)
        symbol_name(value)
      else
        value
      end
    end

    def camelize(str)
      str.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    end

    def random_string(len = 10)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      Array.new(len){||chars[rand(chars.size)]}.join
    end

    def administrator_group_string
      string_name(administrator_group_symbol)
    end

    def administrator_group_symbol
      :administrators
    end

    private

    def string_name(str_sym)
      str_sym.is_a?(Symbol) ? convert_reference_name(str_sym) : str_sym
    end

    def symbol_name(str_sym)
      str_sym.is_a?(String) ? convert_reference_name(str_sym) : str_sym
    end

    def titleize(str)
      humanize(underscore(str)).gsub(/\b([a-z])/) { $1.capitalize }
    end
    
    def humanize(str)
      str.to_s.gsub(/_id$/, "").gsub(/_/, " ").capitalize
    end

    def underscore(str)
      str.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").downcase
    end
  end
end
