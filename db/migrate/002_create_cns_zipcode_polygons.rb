class CreateCnsZipcodePolygons < ActiveRecord::Migration
  def self.up
    create_table :cns_zipcode_polygons do |t|
    end
  end

  def self.down
    drop_table :cns_zipcode_polygons
  end
end
