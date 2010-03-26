class ServiceRequestsController < ApplicationController
  # GET /service_requests
  # GET /service_requests.xml
  def index
    @service_requests = ServiceRequest.find(:all, :order=>'jurisdiction, route')
    #TODO: Limit by geography, jurisdiction, route
    #TODO: Paginate by 50's 
    respond_to do |format|
      format.html {        
        #@pager = Paginator.new(session[:surveys].length, 50) do |offset, per_page|
          #session[:surveys][offset,per_page]
        #end
        #@page_o_surveys = @pager.page(params[:page])
        #build the json for the items' geography
        json = []
        @service_requests.each_with_index do |site, i|
        #@page_o_surveys.each_with_index do |site, i|
          geom = site.pt_geom_4326
          json<<"[#{i}, #{geom.y}, #{geom.x}]" unless (geom.y.nil? || geom.y<38)
        end
        @json="[#{json.join(',')}]"
        #@page_labels={}
        #@pager.each do |page|
          #@page_labels[page.number]= "#{page.items.first.primary_road}"
        #end
      }
      format.xml  { render :xml => @service_requests }
    end
  end
  
  # GET /service_requests/1
  # GET /service_requests/1.xml
  def show
    @service_request = ServiceRequest.find(params[:id])
    #@jurisdiction = @service_request.get_jurisdiction
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service_request }
    end
  end
  
  # GET /service_requests/new
  # GET /service_requests/new.xml
  def new
    @service_request = ServiceRequest.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service_request }
    end
  end
  
  # GET /service_requests/1/edit
  def edit
    @service_request = ServiceRequest.find(params[:id])
  end
  
  # POST /service_requests
  # POST /service_requests.xml
  def create
    params['lat_window']||=nil
    params['lng_window']||=nil
    
    @service_request = ServiceRequest.new(params[:service_request])
    @service_request.pt_geom_4326 = Point.from_x_y(params['lng_window'], params['lat_window'],4326)unless params['lat_window'].nil? || params['lng_window'].nil?
    
    respond_to do |format|
      if @service_request.save
        flash[:notice] = "ServiceRequest was successfully created. Lat #{params['lat_window']}"
        format.html { redirect_to(@service_request) }
        format.xml  { render :xml => @service_request, :status => :created, :location => @service_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_request.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /service_requests/1
  # PUT /service_requests/1.xml
  def update
    @service_request = ServiceRequest.find(params[:id])
    
    respond_to do |format|
      if @service_request.update_attributes(params[:service_request])
        @service_request.pt_geom_4326 = Point.from_x_y(params['lng_window'], params['lat_window'],4326)unless params['lat_window'].nil? || params['lng_window'].nil?
        @service_request.save!
        flash[:notice] = "ServiceRequest was successfully updated. Lat #{params['lat_window']}"
        format.html { redirect_to(@service_request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_request.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /service_requests/1
  # DELETE /service_requests/1.xml
  def destroy
    @service_request = ServiceRequest.find(params[:id])
    @service_request.destroy
    
    respond_to do |format|
      format.html { redirect_to(service_requests_url) }
      format.xml  { head :ok }
    end
  end
end
