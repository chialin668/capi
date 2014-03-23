class CreateCnsZipcodes < ActiveRecord::Migration
  def self.up
    create_table :cns_zipcodes do |t|
    end
  end

  def self.down
    drop_table :cns_zipcodes
  end
end
