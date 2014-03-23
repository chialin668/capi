class CreateCnsStatePolygons < ActiveRecord::Migration
  def self.up
    create_table :cns_state_polygons do |t|
    end
  end

  def self.down
    drop_table :cns_state_polygons
  end
end
