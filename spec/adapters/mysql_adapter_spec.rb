ENV['RAILS_ENV'] ||= 'test_mysql'

require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))
require "foreigner/connection_adapters/mysql_adapter"

class MySQLTestAdapter < AdapterTester
  include Foreigner::ConnectionAdapters::MysqlAdapter

  def schema(table_name)
    ActiveRecord::Base.connection.select_one("SHOW CREATE TABLE #{quote_table_name(table_name)}")["Create Table"]
  end

  def recreate_test_environment
    super(:mysql)
  end
end

describe 'MySQL Adapter' do
  include MigrationFactory

  before(:each) do 
    @adapter = MySQLTestAdapter.new
  end

  describe 'when creating tables' do 
    before(:each) do
      @adapter.recreate_test_environment
    end
    
    # t.foreign_key :farm
    it 'should understand t.foreign_key ' do

      create_table do |t|
        t.string :name
        t.references :collection, :null => false
        t.foreign_key :collection
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\)/)
    end

    # t.foreign_key :farm, :column => :shearing_farm_id
    xit 'should accept a :column parameter' do
      premigrate
      table = "sheep"
      migrate table
      assert_match(/FOREIGN KEY\s*\(\`shearing_farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\)/, schema(table))
    end

    # t.foreign_key :farm, :dependent => :nullify
    xit 'should accept :depenent => :nullify' do
      premigrate
      table = "bears"
      migrate table
      assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\) ON DELETE SET NULL/, schema(table))
    end

    # t.foreign_key :farm, :dependent => :delete
    xit 'should accept :dependent => :delete' do
      premigrate
      table = "elephants"
      migrate table
      assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\) ON DELETE CASCADE/, schema(table))
    end

    # t.references, :foreign_key => true
    xit 'should accept a t.references constraint' do
      premigrate
      table = "pigs"
      migrate table
      assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\)/, schema(table))
    end

    # t.references :farm, :foreign_key => {:dependent => :nullify}
    xit 'should accept :foreign_key => { :dependent => :nullify }' do
      premigrate
      table = "tigers"
      migrate table
      assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\) ON DELETE SET NULL/, schema(table))
    end

    # t.references :farm, :foreign_key => {:dependent => :delete}
    xit 'should accept :foreign_key => { :dependent => :delete }' do
      premigrate
      table = "goats"
      migrate table
      assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\) ON DELETE CASCADE/, schema(table))
    end
  end

  
  describe 'when altering tables' do
    it 'should add foreign key without options' do
      @adapter.add_foreign_key(:employees, :companies).should eql(
        "ALTER TABLE `employees` ADD CONSTRAINT `fk_employees_company_id` FOREIGN KEY (`company_id`) REFERENCES `companies`(id)"
      )
    end

    it 'should add foreign key with a name' do
      @name = 'favorite_company_fk'
      @adapter.add_foreign_key(:employees, :companies, :name => @name).should eql(
        "ALTER TABLE `employees` ADD CONSTRAINT `#{@name}` FOREIGN KEY (`company_id`) REFERENCES `companies`(id)"
      )
    end

    it 'should add foreign key with a column' do
      @column = 'last_employer_id'
      @adapter.add_foreign_key(:employees, :companies, :column => @column).should eql(
        "ALTER TABLE `employees` ADD CONSTRAINT `fk_employees_last_employer_id` FOREIGN KEY (`#{@column}`) REFERENCES `companies`(id)"
      )
      
    end

    it 'should add foreign key with column and a name' do
      @name = 'favorite_company_fk'
      @column = 'last_employer_id'
      @adapter.add_foreign_key(:employees, :companies, :column => @column, :name => @name).should eql(
        "ALTER TABLE `employees` ADD CONSTRAINT `#{@name}` FOREIGN KEY (`#{@column}`) REFERENCES `companies`(id)"
      )
    end

    it 'should add foreign key with :dependent => :delete' do
      @adapter.add_foreign_key(:employees, :companies, :dependent => :delete).should eql(
        "ALTER TABLE `employees` ADD CONSTRAINT `fk_employees_company_id` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
        "ON DELETE CASCADE")
    end

    it 'should add foreign key with :dependent => :nullify' do
      @adapter.add_foreign_key(:employees, :companies, :dependent => :nullify).should eql(
        "ALTER TABLE `employees` ADD CONSTRAINT `fk_employees_company_id` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
        "ON DELETE SET NULL"
      )
    end

    it 'should drop foreign key' do
      @adapter.remove_foreign_key(:suppliers, :companies).should eql(
        "ALTER TABLE `suppliers` DROP FOREIGN KEY `fk_suppliers_company_id`"
      )
    end

    it 'should drop foreign key by name' do
      @adapter.remove_foreign_key(:suppliers, :name => "belongs_to_supplier").should eql(
        "ALTER TABLE `suppliers` DROP FOREIGN KEY `belongs_to_supplier`"
      )
    end

    it 'should drop foreign key by column' do 
      @adapter.remove_foreign_key(:suppliers, :column => "ship_to_id").should eql(
        "ALTER TABLE `suppliers` DROP FOREIGN KEY `fk_suppliers_ship_to_id`"
      )
    end
  end


end

