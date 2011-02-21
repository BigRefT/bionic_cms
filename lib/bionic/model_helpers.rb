module Bionic
  module ModelHelpers

    protected
  
    def update_model(model_string)
      objeck = find_objeck(model_string)
      update_attributes(objeck, model_string)
      save_and_show(objeck, model_string)
    end
  
    def destroy_model(model_string)
      objeck = find_objeck(model_string)
      objeck.destroy
      show_success(model_string, "deleted")
    end
  
    def find_objeck(model_string)
      model_string.constantize.find(params[:id])
    end
  
    def update_attributes(objeck, model_string)
      objeck.attributes = params[model_string.underscore.to_sym]
    end
  
    def save_and_show(objeck, model_string)
      if save_objeck(objeck)
        show_success(model_string)
      else
        show_failure(objeck)
      end
    end
  
    def save_objeck(objeck)
      objeck.save
    end
  
    def show_success(model_string = nil, action = "updated")
      flash[:notice] = "#{model_string.underscore.humanize.titlecase rescue model_string} #{action} successfully." if model_string
      # prevent redirect to another site
      # doing this by making sure the url starts with a '/'
      # not a great way to do it, but it works
      params[:success_url] = params[:success_url] && params[:success_url].first == "/" ? params[:success_url] : nil
      params[:from_url] = params[:from_url] && params[:from_url].first == "/" ? params[:from_url] : nil
      redirect_to (params[:success_url] || params[:from_url]) || (request.headers["Referer"].empty_or_nil? ? "/" : :back)
    end
  
    def show_failure(objeck)
      session[:liquid_assigns] = { 'current_page' => params[:from_url] || "/" }
      session[:liquid_registers] = { (params[:form_uuid] || 'form_register_key') => objeck } if objeck.not_nil?
      # prevent redirect to another site
      # doing this by making sure the url starts with a '/'
      # not a great way to do it, but it works
      params[:from_url] = params[:from_url] && params[:from_url].first == "/" ? params[:from_url] : nil
      redirect_to params[:from_url] || (request.headers["Referer"].empty_or_nil? ? "/" : :back)
    end

  end
end