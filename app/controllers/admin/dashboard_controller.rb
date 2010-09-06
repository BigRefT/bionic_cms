class Admin::DashboardController < ApplicationController
  def index
    @audits = Audit.paginate(:all, :page => params[:page], :order => 'created_at DESC')
  end
end