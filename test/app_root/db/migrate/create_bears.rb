class CreateBears < ActiveRecord::Migration
  def self.up
    create_table :bears do |t|
      t.string :name
      t.references :farm
      t.foreign_key :farm, :dependent => :nullify
    end
  end

  def self.down
    drop_table :bears
  end
end

