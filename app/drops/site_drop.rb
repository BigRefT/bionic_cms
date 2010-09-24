class SiteDrop < Liquid::Drop

  def initialize(kontroller)
    @kontroller = kontroller
  end

  def form_authenticity_token
    kontroller.send(:form_authenticity_token)
  end

  def environment
    Rails.env
  end

  def menus
    SiteMenuCollectionDrop.new
  end

  def draft_mode
    true unless Site.draft_mode.empty_or_nil?
  end

  def flash
    FlashDrop.new(kontroller.send(:flash))
  end

  private

  def current_site
    @current_site ||= Site.current_site
  end

  def kontroller
    @kontroller
  end

end