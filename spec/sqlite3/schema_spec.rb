#ENV['RAILS_ENV'] ||= 'test_mysql'

require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

describe Foreigner::ConnectionAdapters::SQLite3Adapter do
  include MigrationFactory

  before(:each) do 
    @adapter = AdapterHelper::SQLite3TestAdapter.new
    @adapter.recreate_test_environment
    @adapter.schema(:items).should be_nil
  end

  describe 'when creating tables with t.foreign_key' do
    it 'should understand t.foreign_key' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :null => false
        t.foreign_key :collection
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\"collection_id\"\) REFERENCES \"collections\"\s*\(id\)/)
    end

    it 'should accept a :column parameter' do
      @column = :item_collection_id

      create_table :items do |t|
        t.string :name
        t.integer @column
        t.foreign_key :collection, :column => @column
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\"#{@column}\"\) REFERENCES \"collections\"\s*\(id\)/)
    end

    it 'should accept :dependent => :nullify' do
      create_table :items do |t|
        t.string :name
        t.references :collection
        t.foreign_key :collection, :dependent => :nullify
      end     

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\"collection_id\"\) REFERENCES \"collections\"\s*\(id\) ON DELETE SET NULL/)
    end

    it 'should accept :dependent => :delete' do
      create_table :items do |t|
        t.string :name
        t.references :collection
        t.foreign_key :collection, :dependent => :delete
      end     

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\"collection_id\"\) REFERENCES \"collections\"\s*\(id\) ON DELETE CASCADE/)
    end
  end

  describe 'when creating tables with t.reference' do
    it 'should accept a t.references constraint' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => true
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\"collection_id\"\) REFERENCES \"collections\"\s*\(id\)/)
    end

    it 'should accept :foreign_key => { :dependent => :nullify }' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => {:dependent => :nullify}
      end

      @adapter.schema(:items).match(/FOREIGN KEY\s*\(\"collection_id\"\) REFERENCES \"collections\"\s*\(id\) ON DELETE SET NULL/)
    end

    it 'should accept :foreign_key => { :dependent => :delete }' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => {:dependent => :delete}
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\"collection_id\"\) REFERENCES \"collections\"\s*\(id\) ON DELETE CASCADE/)
    end
  end

end

