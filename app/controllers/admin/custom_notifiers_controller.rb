class Admin::CustomNotifiersController < ApplicationController

  # GET /admin/custom_notifiers/new
  def new
    @custom_notifier = CustomNotifier.new
    @custom_notifier.notifier_type = params[:notifier_type]
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /admin/custom_notifiers
  def create
    @custom_notifier = CustomNotifier.new(params[:custom_notifier])
    @custom_notifier.notifier_type = params[:custom_notifier][:notifier_type]

    respond_to do |format|
      if @custom_notifier.save
        # create corresponding notice email
        notice = CustomNotifier.new
        notice.name = "#{params[:custom_notifier][:name]} Notice"
        notice.notifier_type = @custom_notifier.notifier_type
        notice.save

        flash[:notice] = "#{@custom_notifier.notifier_type}: #{@custom_notifier.name} was successfully created."
        format.html { redirect_to(admin_site_emails_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

end
