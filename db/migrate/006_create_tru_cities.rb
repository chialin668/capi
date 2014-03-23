class CreateTruCities < ActiveRecord::Migration
  def self.up
    create_table :tru_cities do |t|
    end
  end

  def self.down
    drop_table :tru_cities
  end
end
