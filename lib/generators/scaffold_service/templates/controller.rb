class <%= controller_class_name %>Controller < ApplicationController
  layout '/layouts/<%=plural_name%>.html.erb'
  # GET /<%= File.join(controller_class_path,plural_name) %>
  # GET /<%= table_name %>.xml
  def index
    
    params[:fields]||=''
    @fields = <%= model_name %>.searches_on(comma_parse_to_a(params[:fields]))
    
    params[:terms]||=''
    @terms = comma_parse_to_a(params[:terms]).join(" OR ")+ ''
    
    params[:showfields]||=''
    @showfields = <%= model_name %>.shows_on(comma_parse_to_a(params[:showfields]))
    
    params[:sortfields]||=''
    sortfields = comma_parse_to_a(params[:sortfields])
    options = {:select=>@showfields.join(',')}
    options[:order]= sortfields if params[:sortfields].length !=0 
    
    @<%= plural_name %> = <%= model_name %>.search_in_for(@fields, @terms, options)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= plural_name %> }
      format.json { render :json=> @<%= plural_name %>}
      format.xls do 
        headers["Content-disposition"] = 'attachment; filename=<%= plural_name %>.xls'
        render :xml =>@<%= plural_name %>
      end
      format.doc do 
        headers["Content-disposition"] = 'attachment; filename=<%= plural_name %>.doc'
      end
    end
  end

# GET /<%= table_name %>/1
# GET /<%= table_name %>/1.xml
def show
@<%= file_name %> = <%= model_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
      format.json { render :json=> @<%= file_name %>}
      format.xls do 
        headers["Content-disposition"] = "attachment; filename=<%= file_name %>_#{@<%= file_name %>.id}.xls"
        render :xml =>@<%= file_name %>
      end
      format.doc do 
        headers["Content-disposition"] = "attachment; filename=<%= file_name %>_#{@<%= file_name %>.id}.doc"
      end
    end
  end

private

  def comma_parse_to_a(string)
    return string.split(',').collect{|field| field.strip}
  end

end
