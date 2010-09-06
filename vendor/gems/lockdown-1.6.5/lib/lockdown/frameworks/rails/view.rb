module Lockdown
  module Frameworks
    module Rails
      module View
        def self.included(base)
          base.class_eval do
            alias_method :link_to_open, :link_to
            alias_method :link_to, :link_to_secured

            alias_method :button_to_open, :button_to
            alias_method :button_to, :button_to_secured
          end
        end

        def link_to_secured(name, options = {}, html_options = nil)
          url = url_for(options)

          method = html_options && html_options[:method] ? html_options[:method] : :get

          if authorized?(url, method)
            return link_to_open(name, url, html_options)
          end
          return ""
        end

        def button_to_secured(name, options = {}, html_options = nil)
          url = url_for(options)

          method = html_options ? html_options[:method] : :get

          if authorized?(url, method)
            return button_to_open(name, url, html_options)
          end
          return ""
        end

        def link_to_or_show(name, options = {}, html_options = nil)
          lnk = link_to(name, options, html_options)
          lnk.length == 0 ? name : lnk
        end

        def links(*lis)
          rvalue = []
          lis.each{|link| rvalue << link if link.length > 0 }
          rvalue.join( Lockdown::System.fetch(:link_separator) )
        end
      end # View
    end # Rails
  end # Frameworks
end # Lockdown

