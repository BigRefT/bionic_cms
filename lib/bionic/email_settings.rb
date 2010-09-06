require 'singleton'

module Bionic
  class EmailSettings
    include Singleton

    attr_accessor :notifiers

    def initialize
      @notifiers = []
    end
    
    def notifier_by_name(name)
      @notifiers.each do |notifier|
        return notifier if notifier[:name] == name
      end
      nil
    end

  end
end