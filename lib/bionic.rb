BIONIC_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..")) unless defined? BIONIC_ROOT

unless defined? Bionic::Version
  module Bionic
    module Version
      Major = '0'
      Minor = '1'
      Tiny  = '0'
      Patch = nil # set to nil for normal release

      class << self
        def to_s
          [Major, Minor, Tiny, Patch].delete_if{|v| v.nil? }.join('.')
        end
        alias :to_str :to_s
      end
    end
  end
end

unless defined? Bionic::ImageContentTypes
  module Bionic
    ImageContentTypes = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg']

    QuotedAttribute = /"([^"]+)"|'([^']+)'/
    EmailValidation = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    PhoneValidation = /^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$/
  end
end
