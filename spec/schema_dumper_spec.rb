require File.expand_path('spec_helper.rb', File.dirname(__FILE__))

class SchemaDumperTester

  def tables(stream)
    stream
  end

  include Foreigner::SchemaDumper
  include ForeignKeyDefinitionFactory

  def valid_foreign_key_definition(opt = {})
    options = {
      :from_table => 'items',
      :to_table => 'collections'
    }.merge(opt)
  end

  # Helper when we want to test a single generated statement
  def generate_schema_statement(foreign_key_definition)
    fkd = new_foreign_key(foreign_key_definition)
    generate_foreign_keys_statements([fkd]).first
  end
end

describe Foreigner::SchemaDumper do

  before(:each) do 
    @dumper = SchemaDumperTester.new
    @fk_definition = {
      :from_table => 'items',
      :to_table => 'collections'
    }

    # Sanity Check
    fkd = @dumper.new_foreign_key(@fk_definition)
    fkd.from_table.should eql('items')
    fkd.to_table.should eql('collections')
  end

  it 'should generate an add_foreign_key' do
    @dumper.generate_schema_statement(@fk_definition).should match(/\s*add_foreign_key\s+:items,\s:collections/)
  end

  it 'should generate with a custom foreign key name' do
    @foreign_key_name = 'fk_foreign_key_name'
    @dumper.generate_schema_statement(:name => @foreign_key_name).should match(
      /\s*add_foreign_key\s+:items,\s:collections,\s+:name\s+=>\s+\"#{@foreign_key_name}\"/
    )
  end

  it 'should generate with a custom column id' do
    @column = 'acctno'
    @dumper.generate_schema_statement(:column => @column).should match(
      /\s*add_foreign_key\s+:items,\s:collections,\s+:column\s+=>\s+\"#{@column}\"/
    )
  end

  it 'should ignore custom column id conforming to Rails convention'
  it 'should generate with a custom primary key'
  it 'should ignore custom primary key conforming to Rails convention'
  it 'should generate with a :dependent => :nullify'
  it 'should generate with a :dependent => :delete'

end

