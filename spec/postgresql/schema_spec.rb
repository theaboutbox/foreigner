require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

describe Foreigner::ConnectionAdapters::PostgreSQLAdapter do
  include MigrationFactory

  before(:each) do 
    @adapter = AdapterHelper::PostgreSQLTestAdapter.new
    @adapter.recreate_test_environment
  end

  describe 'when creating tables with t.foreign_key' do 

    it 'should understand t.foreign_key' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :null => false
        t.foreign_key :collection
      end

      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.to_table.should eql('collections')
      foreign_key.options[:primary_key].should eql('id')
      foreign_key.options[:column].should eql('collection_id')
      foreign_key.options[:dependent].should be_nil
    end

    it 'should use a default foreign key name'
    it 'should use a conventional primary key'
    it 'should use a conventional column id'

    it 'should accept a :column parameter' do
      @column = :item_collection_id

      create_table :items do |t|
        t.string :name
        t.integer @column
        t.foreign_key :collection, :column => @column
      end

      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.to_table.should eql('collections')
      foreign_key.options[:primary_key].should eql('id')
      foreign_key.options[:column].should eql(@column.to_s)
      foreign_key.options[:dependent].should be_nil
    end

    it 'should accept :dependent => :nullify' do
      @dependent = :nullify
      create_table :items do |t|
        t.string :name
        t.references :collection
        t.foreign_key :collection, :dependent => @dependent
      end     

      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.to_table.should eql('collections')
      foreign_key.options[:primary_key].should eql('id')
      foreign_key.options[:column].should eql('collection_id')
      foreign_key.options[:dependent].should eql(@dependent)
    end

    it 'should accept :dependent => :delete' do
      @dependent = :delete
      create_table :items do |t|
        t.string :name
        t.references :collection
        t.foreign_key :collection, :dependent => @dependent
      end     

      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.to_table.should eql('collections')
      foreign_key.options[:primary_key].should eql('id')
      foreign_key.options[:column].should eql('collection_id')
      foreign_key.options[:dependent].should eql(@dependent)
    end
  end

  describe 'when creating tables with t.reference' do

    it 'should accept a t.references constraint' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => true
      end

      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.to_table.should eql('collections')
      foreign_key.options[:primary_key].should eql('id')
      foreign_key.options[:column].should eql('collection_id')
      foreign_key.options[:dependent].should be_nil
    end

    it 'should accept :foreign_key => { :dependent => :nullify }' do
      @dependent = :nullify
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => {:dependent => @dependent}
      end

      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.to_table.should eql('collections')
      foreign_key.options[:primary_key].should eql('id')
      foreign_key.options[:column].should eql('collection_id')
      foreign_key.options[:dependent].should eql(@dependent)
    end

    it 'should accept :foreign_key => { :dependent => :delete }' do
      @dependent = :delete
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => {:dependent => @dependent}
      end

      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.to_table.should eql('collections')
      foreign_key.options[:primary_key].should eql('id')
      foreign_key.options[:column].should eql('collection_id')
      foreign_key.options[:dependent].should eql(@dependent)
    end
  end

end

