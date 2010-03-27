class CreateElephants < ActiveRecord::Migration
  def self.up
    create_table :elephants do |t|
      t.string :name
      t.references :farm
      t.foreign_key :farm, :dependent => :delete
    end
  end

  def self.down
    drop_table :elephants
  end
end

