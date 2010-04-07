require File.expand_path('spec_helper.rb', File.dirname(__FILE__))

class SchemaDumperTester

  def tables(stream)
    stream
  end

  include Foreigner::SchemaDumper

  # Helper when we want to test a single generated statement
  def generate_schema_statement(foreign_key_definition)
    generate_foreign_keys_statements([foreign_key_definition]).first
  end
end

describe Foreigner::SchemaDumper do

  before(:each) do 
    @dumper = SchemaDumperTester.new
  end

  it 'should generate an add_foreign_key'
  it 'should generate with a default foreign key name'
  it 'should generate with the referenced table'
  it 'should generate with a custom column id'
  it 'should generate with a custom primary key'
  it 'should generate with a :dependent => :nullify'
  it 'should generate with a :dependent => :delete'

end

