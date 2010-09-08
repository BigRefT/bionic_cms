class SiteDrop < Liquid::Drop

  private

  def current_site
    @current_site ||= Site.current_site
  end

end