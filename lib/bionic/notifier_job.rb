module Bionic

  class NotifierJob < Struct.new(:site_id, :draft_mode, :method_name, :site_email_id, :parameters)

    def perform
      Site.current_site_id = site_id
      Site.draft_mode = draft_mode
      Notifier.send("deliver_#{method_name}_#{site_email_id}".to_sym, *parameters)
    end

  end

end