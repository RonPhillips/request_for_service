class ScaffoldingSandbox
  include ActionView::Helpers::ActiveRecordHelper
  
  attr_accessor :form_action, :singular_name, :suffix, :model_instance, :plural_name
  
  def sandbox_binding
    binding
  end
  
  def default_show_block
    Proc.new { |record, column| "<p><b>#{column.human_name}: </b><%=@#{record}.#{column.name}%></p>\n" }
  end
  
  def default_index_block
    Proc.new { |record, column| "<td><%=#{singular_name}.#{column.name}%></td>\n" }
  end
  
  def default_index_header
    Proc.new { |record, column| "<th>#{column.human_name}</th>\n" }
  end
  
end


module ActionView::Helpers::ActiveRecordHelper
  
  def all_show_tags(record, record_name, options)
    show_block = options[:show_block] || default_show_block
    skip_columns = ["lock_version"]
    @results = record.class.content_columns.collect do |column|
      unless skip_columns.detect{|c| c == column.name}  || column.name.last(3) == "id"
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
      unless skip_columns.detect{|c| c == column.name}  || column.name.last(3) == "id"
        index_header.call(record_name, column) 
      end
    end
    rows = record.class.content_columns.collect do |column|
      unless skip_columns.detect{|c| c == column.name}  || column.name.last(3) == "id"
        index_block.call(record_name, column) 
      end
    end
    
    @results='<table><tr>'
    @results<<header.join("")
    @results<<'</tr>'
    @results<<"<% for #{singular_name} in @#{plural_name} %><tr>"
    @results<<rows.join("")
    @results<<"<td><%= link_to 'Show', #{singular_name} %></td>\n"
    @results<<"</tr><% end %></table>"
    return @results
    
  end
  
end


class ScaffoldServiceGenerator < Rails::Generator::NamedBase
  attr_reader   :model_name,
  :controller_name,
  :controller_class_path,
  :controller_file_path,
  :controller_class_nesting,
  :controller_class_nesting_depth,
  :controller_class_name,
  :controller_singular_name,
  :controller_plural_name,
  :controller_class_name_without_nesting
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    
    # Take controller name from the next argument.  Default to the pluralized model name.
    @controller_name = args.shift
    @controller_name ||= ActiveRecord::Base.pluralize_table_names ? @name.pluralize : @name
    
    @base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(@base_name)
    @model_name = model_name
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
      
      # Controllers and views directories.
      m.directory File.join('app/controllers', controller_class_path)
      m.directory File.join('app/views', controller_class_path, controller_file_name)
      m.directory File.join('app/views', controller_class_path, 'layouts')

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

      # Scaffolded show doc.
      m.complex_template "show.rhtml",
      File.join('app/views',
      controller_class_path,
      controller_file_name,
                  "show.doc.erb"),
      :insert => 'show_scaffolding.rhtml',
      :sandbox => lambda { create_sandbox },
      :begin_mark => 'reflection',
      :end_mark => 'eoreflection',
      :mark_id => singular_name
      
      # Scaffolded index view.
      m.complex_template "ser.index.html.erb",
      File.join('app/views',
      controller_class_path,
      controller_file_name,
                  "index.html.erb"),
      :insert => 'index_scaffolding.rhtml',
      :sandbox => lambda { create_sandbox },
      :begin_mark => 'reflection',
      :end_mark => 'eoreflection',
      :mark_id => plural_name
      
      # Scaffolded index doc.
      m.complex_template "ser.index.html.erb",
      File.join('app/views',
      controller_class_path,
      controller_file_name,
                  "index.doc.erb"),
      :insert => 'index_scaffolding.rhtml',
      :sandbox => lambda { create_sandbox },
      :begin_mark => 'reflection',
      :end_mark => 'eoreflection',
      :mark_id => plural_name
      
      
      # Search library
      m.template('search.rb', File.join('lib', 'search.rb'))
      m.template('service.rb', 'app/models/service.rb')
      m.template('services_controller.rb','app/controllers/services_controller.rb')
      
# Layout and usage page.
      m.template('layout.html.erb', File.join('app/views/', controller_class_path, "layouts/#{controller_file_name}.html.erb"))
      m.template('ser.usage.index.html.erb', File.join('app/views', controller_class_nesting,"index.html.erb"))
      
      m.template(
        'controller.rb', File.join("app/controllers",controller_class_path, "#{controller_file_name}_controller.rb")
      )
      
      #m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      #m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))
      
      m.route_resources controller_file_name
      
    end
    
  end
  
  protected
  # Override with your own usage banner.
  def banner
      "Usage: #{$0} scaffold_service ModelName [ControllerName] Typically, the services are in a namespaced controller, like: Services::ModelName "
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
