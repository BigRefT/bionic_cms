require 'singleton'

module Bionic
  class FormForOptions
    include Singleton
    
    attr_accessor :custom_actions
    
    def initialize
      @custom_actions = []
    end
  end
end