class Service
  def Service.list
    the_list = Dir.new("#{RAILS_ROOT}/app/controllers/services/").entries.sort.delete_if { |x| ! (x =~ /_controller.rb$/) }
    the_list.collect! do |item|
      item.gsub(/_controller.rb/, '')
    end
    return the_list
    
  end
  
end
