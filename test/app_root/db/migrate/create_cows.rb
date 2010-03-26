class CreateCows < ActiveRecord::Migration
  def self.up
    create_table :cows do |t|
      t.string :name
      t.references :farm, :null => false
      t.foreign_key :farms
    end
  end

  def self.down
    drop_table :cows
  end
end

