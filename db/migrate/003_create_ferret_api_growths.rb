class CreateFerretApiGrowths < ActiveRecord::Migration
  def self.up
    create_table :ferret_api_growths do |t|
    end
  end

  def self.down
    drop_table :ferret_api_growths
  end
end
