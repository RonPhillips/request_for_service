class AddRfsGeom < ActiveRecord::Migration
  def self.up
      add_column :service_requests, :the_geom_4269, :point, :srid =>4269
      add_column :service_requests, :the_geom_3734, :point, :srid =>3734
  end
  
  def self.down
      remove_column :service_requests, :the_geom_4269
      remove_column :service_requests, :the_geom_3734
  end
end
