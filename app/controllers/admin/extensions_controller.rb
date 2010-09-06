class Admin::ExtensionsController < ApplicationController
  def index
    @extensions = Bionic::Extension.descendants.sort_by { |e| e.extension_name }
  end
end
