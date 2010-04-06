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
    
    it 'should understand t.foreign_key ' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :null => false
        t.foreign_key :collection
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\)/)
    end

    it 'should accept a :column parameter' do
      @column = :item_farm_id

      create_table :items do |t|
        t.string :name
        t.integer :item_farm_id
        t.foreign_key :collection, :column => @column
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`#{@column}\`\) REFERENCES \`collections\`\s*\(\`id\`\)/)
    end

    it 'should accept :depenent => :nullify' do
      create_table :items do |t|
        t.string :name
        t.references :collection
        t.foreign_key :collection, :dependent => :nullify
      end     
      
      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE SET NULL/)
    end

    it 'should accept :dependent => :delete' do
      create_table :items do |t|
        t.string :name
        t.references :collection
        t.foreign_key :collection, :dependent => :delete
      end     

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE CASCADE/)
    end

    it 'should accept a t.references constraint' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => true
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\)/)
    end

    it 'should accept :foreign_key => { :dependent => :nullify }' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => {:dependent => :nullify}
      end

      @adapter.schema(:items).match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE SET NULL/)
    end

    it 'should accept :foreign_key => { :dependent => :delete }' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => {:dependent => :delete}
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE CASCADE/)
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

