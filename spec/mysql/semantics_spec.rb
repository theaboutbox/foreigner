require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

describe Foreigner::ConnectionAdapters::MysqlAdapter do
  include MigrationFactory

  before(:each) do 
    @adapter = AdapterHelper::MySQLTestAdapter.new
  end

  describe 'when adding foreign keys' do
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
  end

  describe 'when dropping foreign keys' do
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

