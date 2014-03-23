class CreateCnsStates < ActiveRecord::Migration
  def self.up
    create_table :cns_states do |t|
    end
  end

  def self.down
    drop_table :cns_states
  end
end
