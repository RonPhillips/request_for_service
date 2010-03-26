require 'geo_ruby'
include GeoRuby::SimpleFeatures

class ServiceRequest < ActiveRecord::Base
  def get_jurisdiction
    out=Jurisdiction.find_by_sql("SELECT * FROM jurisdictions AS j, service_requests AS r WHERE ST_Contains(j.the_geom_3734,r.the_geom_3734) AND r.id=#{id} ")
    return out.first
  end
  def update_4326_gcs(lat=nil, lng=nil)
    unless lat.nil? || lng.nil?  
      self.pt_geom_4326 = Point.from_x_y(lng, lat, 4326)
    end
  end
  #TODO:UPDATE service_requests SET pt_geom_3734= ST_Transform(pt_geom_4326, 3734);

end
