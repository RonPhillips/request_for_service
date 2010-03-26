class AddRfsText < ActiveRecord::Migration
  def self.up
    create_table "service_requests" do |t|
      t.string :title
      t.string :content
      t.string :requester_first_name
      t.string :requester_family_name
      t.string :requester_tor
      t.string :request_address
      t.string :request_jurisdiction
      t.string :status
      t.string :created_by
      t.string :updated_by
      t.timestamps
    end
    
  end
  
  def self.down
    drop_table "service_requests"
  end
end
