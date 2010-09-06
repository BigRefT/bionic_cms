module Admin::RegionsHelper
  def render_region(region, options={}, &block)
    lazy_initialize_region_set(region)
    default_partials = Bionic::AdminInterface::RegionPartials.new(self)
    if block_given?
      block.call(default_partials)
      (options[:locals] ||= {}).merge!(:defaults => default_partials)
    end
    output = @region_set[region].compact.map do |partial|
      begin
        # right_side region is special
        render_partial = region.to_s.starts_with?("right_side") ? "/admin/right_side/#{@controller_name}/#{partial}" : partial
        render options.merge(:partial => render_partial)
      rescue ::ActionView::MissingTemplate # couldn't find template
        default_partials[partial]
      rescue ::ActionView::TemplateError => e # error in template
        raise e
      end
    end.join
    block_given? ? concat(output) : output
  end

  def lazy_initialize_region_set(region)
    # these are global regions displayed in the admin layout
    # only load values if we have a specific region and it hasn't been before
    if [:site_top_left_menu, :site_top_right_menu].include?(region) 
      if @template_name != "top_menu"
        @controller_name = "site"
        @template_name = "top_menu"
        @region_set = admin_interface.send(@controller_name).send(@template_name)
      end
    # this is for everything else
    # try to only do it once
    # so if region set is null or we are coming from one of the globals
    elsif @region_set.nil? || @template_name == "top_menu"
      @controller_name = @controller.controller_name
      @template_name = @controller.template_name
      @region_set = admin_interface.send(@controller_name).send(@template_name)
    end
  end
end