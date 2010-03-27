class CreateGoats < ActiveRecord::Migration
  def self.up
    create_table :goats do |t|
      t.string :name
      t.references :farm, :foreign_key => {:dependent => :delete}
    end
  end

  def self.down
    drop_table :goats
  end
end

