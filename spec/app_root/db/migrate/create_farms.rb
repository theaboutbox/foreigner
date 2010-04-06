class CreateFarms < ActiveRecord::Migration
  def self.up
    create_table :farms do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :farms
  end
end

