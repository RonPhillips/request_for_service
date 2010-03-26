class ScaffoldingSandbox
  include ActionView::Helpers::ActiveRecordHelper
  
  attr_accessor :form_action, :singular_name, :suffix, :model_instance, :plural_name
  
  def sandbox_binding
    binding
  end
  
  def default_input_block
    Proc.new { |record, column| "<p><label for=\"#{record}_#{column.name}\">#{column.human_name}</label><br />\n#{input(record, column.name)}</p>\n" }
  end
  
  def default_show_block
    Proc.new { |record, column| "<p><b>#{column.human_name}: </b><%= default_format(@#{record}, '#{column.name}')%></p>\n" }
  end
  
  def default_index_block
    Proc.new { |record, column| "<td><%=default_format(#{singular_name},'#{column.name}')%></td>\n" }
  end
  
  def default_index_header
    Proc.new { |record, column| "<th>#{column.human_name}</th>\n" }
  end
  
  def blocked_index_block
    Proc.new {|record, column|"<!--<td><|=default_format(#{singular_name},'#{column.name}')|></td>--><!--type:#{column.type}, limit:#{column.limit}-->\n" }
  end
  
  def blocked_index_header
    Proc.new { |record, column| "<!--<th>#{column.human_name}</th>-->\n" }
  end
end


module ActionView::Helpers::ActiveRecordHelper
  
  def all_input_tags(record, record_name, options)
    input_block = options[:input_block] || default_input_block
    skip_columns = ["created_at", "lock_version", "created_on", "updated_at", "updated_on"]
    @results = record.class.content_columns.collect do |column|
      unless skip_columns.detect{|c| c == column.name}  #|| column.name.last(3) == "id"
        input_block.call(record_name, column) 
      end
    end
    @results.join("")
    
  end
  def all_show_tags(record, record_name, options)
    show_block = options[:show_block] || default_show_block
    skip_columns = ["lock_version"]
    @results = record.class.content_columns.collect do |column|
      unless skip_columns.detect{|c| c == column.name}  #|| column.name.last(3) == "id"
        show_block.call(record_name, column) 
      end
    end
    @results.join("")
    
  end
  
  def all_index_tags(record, record_name, options)
    index_block = options[:index_block] || default_index_block
    index_header = options[:index_header] || default_index_header
    skip_columns = ["lock_version"]
    header = record.class.content_columns.collect do |column|
      unless skip_columns.detect{|c| c == column.name}  #|| column.name.last(3) == "id"
        index_header.call(record_name, column) 
      end
    end
    rows = record.class.content_columns.collect do |column|
      unless skip_columns.detect{|c| c == column.name}  #|| column.name.last(3) == "id"
        index_block.call(record_name, column) 
      end
    end
    
    
    @results='<table id="results" class="tablesorter"><thead><tr>'
    @results<<header.join("")
    @results<<'</tr></thead><tbody>'
    @results<<"<% for #{singular_name} in @#{plural_name} %><tr>"
    @results<<rows.join("")
    @results<<"<td><%= link_to 'Show', #{singular_name} %></td>\n"
    @results<<"<td><%= link_to 'Edit', edit_#{singular_name}_path(#{singular_name}) %></td>\n"
    @results<<"<td><%= link_to 'Destroy', #{singular_name}, :confirm => 'Are you sure?', :method => :delete %></td>\n"
    @results<<"</tr><% end %></tbody></table>"
    return @results
    
  end
  def typical_index_tags(record, record_name, options)
    index_block = options[:index_block] || default_index_block
    index_header = options[:index_header] || default_index_header
    column_count = options[:column_count] || record.class.columns.length
    use_columns = record.class.columns.collect do |column|
      unless column.type.to_s=='text' || column.type.to_s=='binary'
        if column.limit.nil?
          column.name
        elsif  column.limit<400
          column.name 
        end
      else
      end
    end
    use_columns=use_columns.first(column_count)
    header = record.class.columns.collect do |column|
      if use_columns.detect{|c| c == column.name}
        index_header.call(record_name, column)
      else
        blocked_index_header.call(record_name, column)
      end
    end
    rows = record.class.columns.collect do |column|
      if use_columns.detect{|c| c == column.name}
        index_block.call(record_name, column) 
      else
        blocked_index_block.call(record_name, column)
      end
    end
    
    
    @results='<table id="results" class="tablesorter"><thead><tr>'
    @results<<header.join("")
    @results<<'</tr></thead><tbody>'
    @results<<"<% for #{singular_name} in @#{plural_name} %><tr>"
    @results<<rows.join("")
    @results<<"<td><%= link_to 'Show', #{singular_name} %></td>\n"
    @results<<"<td><%= link_to 'Edit', edit_#{singular_name}_path(#{singular_name}) %></td>\n"
    @results<<"<td><%= link_to 'Destroy', #{singular_name}, :confirm => 'Are you sure?', :method => :delete %></td>\n"
    @results<<"</tr><% end %></tbody></table>"
    return @results
  end

  
#  def all_associations(record)
#    
#    @results =""
#    puts record.class.reflect_on_all_associations.inspect
#    record.class.reflect_on_all_associations.each do |a|
#      puts a.inspect
#      if a.macro == :belongs_to
#        @results += "<p>#{a.klass}<br/><%=f.select #{a.klass}.find(:all).collect {|i| [ p.inspect, p.id ] }, { :include_blank => true }) %>"
#      end
#      
#    end
#    
#    @results
#  end
  
end


class ActionView::Helpers::InstanceTag
  
  def to_tag(options = {})
    case column_type
      when :string
      field_type = @method_name.include?("password") ? "password" : "text"
      to_input_field_tag(field_type, options)
      when :text
      to_text_area_tag(options)
      when :integer, :float, :decimal
      to_input_field_tag("text", options)
      when :date
      to_date_select_tag(options)
      when :datetime, :timestamp
      to_datetime_select_tag(options)
      when :time
      to_time_select_tag(options)
      when :boolean
      to_boolean_checkbox_tag(options)
    end
  end
  
  def to_input_field_tag(field_type, options={})
    field_meth = "#{field_type}_field"
    "<%= f.#{field_meth} '#{@method_name}' #{options.empty? ? '' : ', '+options.inspect} %>"
  end
  
  def to_boolean_checkbox_tag(options = {})
    "<%= f.check_box '#{@method_name}' #{options.empty? ? '' : ', '+ options.inspect} %>"
  end
  
  def to_text_area_tag(options = {})
    "<%= f.text_area '#{@method_name}' #{options.empty? ? '' : ', '+ options.inspect} %>"
  end
  
  def to_date_select_tag(options = {})
    "<%= f.date_select '#{@method_name}' #{options.empty? ? '' : ', '+ options.inspect} %>"
  end
  
  def to_datetime_select_tag(options = {})
       "<%= f.datetime_select '#{@method_name}' #{options.empty? ? '' : ', '+ options.inspect} %>"
  end
  
  def to_time_select_tag(options = {})
    "<%= f.time_select '#{@method_name}' #{options.empty? ? '' : ', '+ options.inspect} %>"
  end
end

class ScaffoldReflectGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
  :controller_class_path,
  :controller_file_path,
  :controller_class_nesting,
  :controller_class_nesting_depth,
  :controller_class_name,
  :controller_singular_name,
  :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    
    # Take controller name from the next argument.  Default to the pluralized model name.
    @controller_name = args.shift
    @controller_name ||= ActiveRecord::Base.pluralize_table_names ? @name.pluralize : @name
    
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)
    
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
  end
  
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}ControllerTest", "#{controller_class_name}Helper"
      
      # Controller, helper, views, and test directories.
      m.directory File.join('app/views', controller_class_path, controller_file_name)
      
      # Scaffolded Model
      m.template "model.rb", File.join('app/models', "#{singular_name}.rb")
      
      # Scaffolded _form.
      m.complex_template "form.rhtml",
      File.join('app/views',
      controller_class_path,
      controller_file_name,
                  "_form.html.erb"),
      :insert => 'form_scaffolding.rhtml',
      :sandbox => lambda { create_sandbox },
      :begin_mark => 'form',
      :end_mark => 'eoform',
      :mark_id => singular_name
      
      # Scaffolded edit and new views.
      scaffold_forms.each do |action|
        m.template "view_#{action}.rhtml",
        File.join('app/views',
        controller_class_path,
        controller_file_name,
        "#{action}.html.erb"),
        :assigns => { :action => action }
      end
      
      # Scaffolded show view.
      m.complex_template "show.rhtml",
      File.join('app/views',
      controller_class_path,
      controller_file_name,
                  "show.html.erb"),
      :insert => 'show_scaffolding.rhtml',
      :sandbox => lambda { create_sandbox },
      :begin_mark => 'reflection',
      :end_mark => 'eoreflection',
      :mark_id => singular_name
      
      # Scaffolded index view.
      m.complex_template "index.rhtml",
      File.join('app/views',
      controller_class_path,
      controller_file_name,
                  "index.html.erb"),
      :insert => 'index_scaffolding.rhtml',
      :sandbox => lambda { create_sandbox },
      :begin_mark => 'reflection',
      :end_mark => 'eoreflection',
      :mark_id => plural_name
      
      
      # Layout and stylesheet.
            # Controller, helper, views, and test directories.
      m.directory File.join('app/views/layouts', controller_class_path)
      m.template('layout.html.erb', File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.html.erb"))
      m.template('layout.html.erb', File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.html.erb"))
	    m.template('layout.html.erb', File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.html.erb"))
      m.template('style.css', 'public/stylesheets/scaffold.css')
      m.template('header.html.erb','app/views/layouts/_header.html.erb')
      m.template('application_helper.rb', 'app/helpers/application_helper.rb')
      #m.dependency 'model', [name] + @args, :collision => :skip
      
      m.directory File.join('app/controllers', controller_class_path)
      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )
      
      m.directory File.join('test/functional', controller_class_path)
      m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      
      m.directory File.join('app/helpers', controller_class_path)
      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))
      
      m.route_resources controller_file_name
      
    end
    
  end
  
  protected
  # Override with your own usage banner.
  def banner
      "Usage: #{$0} scaffold_reflect ModelName [ControllerName]"
  end
  
  def scaffold_forms
      %w(new edit)
  end
  
  def model_name 
    class_name.demodulize
  end
  
  def suffix
      "_#{singular_name}" if options[:suffix]
  end
  
  def create_sandbox
    sandbox = ScaffoldingSandbox.new
    sandbox.singular_name = singular_name
    sandbox.plural_name = plural_name
    
    begin
      sandbox.model_instance = model_instance
      sandbox.instance_variable_set("@#{singular_name}", sandbox.model_instance)
    rescue ActiveRecord::StatementInvalid => e
      logger.error "Before updating scaffolding from new DB schema, try creating a table for your model (#{class_name})"
      raise SystemExit
    end
    sandbox.suffix = suffix
    sandbox
  end
  
  def model_instance
    base = class_nesting.split('::').inject(Object) do |base, nested|
      break base.const_get(nested) if base.const_defined?(nested)
      base.const_set(nested, Module.new)
    end
    unless base.const_defined?(@class_name_without_nesting)
      base.const_set(@class_name_without_nesting, Class.new(ActiveRecord::Base))
    end
    class_name.constantize.new
  end
end
