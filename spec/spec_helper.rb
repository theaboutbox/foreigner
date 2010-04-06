
require 'rubygems'

require 'active_support'
require 'active_record'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'active_record/connection_adapters/mysql_adapter'
require 'foreigner'

require File.expand_path('factory_helper.rb', File.dirname(__FILE__))

CONFIGURATIONS = {
  :postgresql => {
    :adapter => "postgresql",
    :username => "root",
    :password => "",
    :database => "test_foreigner_plugin",
    :min_messages => "ERROR"
  },
  :mysql => {
    :adapter => 'mysql',
    :host => 'localhost',
    :username => 'root',
    :database => 'foreigner_test'

  }, 
  :sqlite3 => {
    :adapter => "sqlite3",
    :database => ":memory:"
  }
}

class AdapterTester
  def recreate_test_environment(env)
    ActiveRecord::Base.establish_connection(CONFIGURATIONS[env])

    @database = CONFIGURATIONS[env][:database]
    ActiveRecord::Base.connection.drop_database(@database)
    ActiveRecord::Base.connection.create_database(@database)
    ActiveRecord::Base.connection.reset!

    FactoryHelpers::CreateCollection.up
  end

  def schema(table_name)
    raise 'This method must be overridden'
  end

  private

  def execute(sql, name = nil)
    sql
  end

  def quote_column_name(name)
    "`#{name}`"
  end

  def quote_table_name(name)
    quote_column_name(name).gsub('.', '`.`')
  end

end


