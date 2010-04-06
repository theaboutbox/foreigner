class CreateTigers < ActiveRecord::Migration
  def self.up
    create_table :tigers do |t|
      t.string :name
      t.references :farm, :foreign_key => {:dependent => :nullify}
    end
  end

  def self.down
    drop_table :tigers
  end
end

