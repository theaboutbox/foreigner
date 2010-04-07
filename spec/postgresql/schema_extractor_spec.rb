require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

describe Foreigner::ConnectionAdapters::PostgreSQLAdapter do
  include MigrationFactory

  before(:each) do 
    @adapter = AdapterHelper::PostgreSQLTestAdapter.new
    @adapter.recreate_test_environment
  end

  describe 'when extracting foreign keys from a table' do 
    it 'should extract single foreign key'  do
      create_table :items do |t|
        t.string :name
        t.references :collection, :null => false
        t.foreign_key :collection
      end

      @adapter.foreign_keys(:items).length.should eql(1)
      foreign_key = @adapter.foreign_keys(:items)[0]

      # Duck Typing
      foreign_key.should be_respond_to(:from_table)
      foreign_key.should be_respond_to(:to_table)
      foreign_key.should be_respond_to(:options)
    end

    it 'should extract multiple foreign keys' do
      create_table :owners do |t|
        t.string :name
      end

      create_table :items do |t|
        t.string :name
        t.references :collection, :null => false
        t.foreign_key :collection
        t.references :owner, :null => false
        t.foreign_key :owner
      end

      @adapter.foreign_keys(:items).length.should eql(2)
      foreign_key_names = @adapter.foreign_keys(:items).map(&:to_table)
      foreign_key_names.should be_include('collections')
      foreign_key_names.should be_include('owners')
    end

    it 'should extract referencing table' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :null => false
        t.foreign_key :collection
      end

      @adapter.foreign_keys(:items).length.should eql(1)
      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.from_table.should eql('items')
    end

    it 'should extract foreign table' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :null => false
        t.foreign_key :collection
      end

      @adapter.foreign_keys(:items).length.should eql(1)
      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.to_table.should eql('collections')
    end

    it 'should extract foreign key name'
    it 'should extract foreign column'
    it 'should extract id'
    it 'should extract :dependent => :nullify'
    it 'should extract :dependent => :delete'
  end

end

