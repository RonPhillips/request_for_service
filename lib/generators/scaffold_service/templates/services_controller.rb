class ServicesController < ApplicationController
  # GET services/
  def index
    @services = Service.list
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
