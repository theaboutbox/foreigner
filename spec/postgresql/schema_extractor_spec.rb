require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

describe Foreigner::ConnectionAdapters::PostgreSQLAdapter do
  include MigrationFactory

  before(:each) do 
    @adapter = AdapterHelper::PostgreSQLTestAdapter.new
    @adapter.recreate_test_environment
  end

  describe 'when extracting foreign keys from a table' do 
    it 'should extract single foreign key' 
    it 'should extract multiple foreign keys'
    it 'should extract referencing table'
    it 'should extract foreign table'
    it 'should extract foreign key name'
    it 'should extract foreign column'
    it 'should extract id'
    it 'should extract :dependent => :nullify'
    it 'should extract :dependent => :delete'
  end

end

