
# CONFIGURATIONS is defined in spec_helper

module AdapterHelper
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

  class PostgreSQLTestAdapter < AdapterTester
    include Foreigner::ConnectionAdapters::PostgreSQLAdapter

    def recreate_test_environment
      super(:postgresql)
    end
  end

  class MySQLTestAdapter < AdapterTester
    include Foreigner::ConnectionAdapters::MysqlAdapter

    def schema(table_name)
      ActiveRecord::Base.connection.select_one("SHOW CREATE TABLE #{quote_table_name(table_name)}")["Create Table"]
    end

    def recreate_test_environment
      super(:mysql)
    end
  end

  class SQLite3TestAdapter < AdapterTester
    include Foreigner::ConnectionAdapters::SQLite3Adapter

    def schema(table_name) ActiveRecord::Base.connection.select_value %{
        SELECT sql
        FROM sqlite_master
        WHERE name = '#{table_name}'
      }
    end

    def recreate_test_environment
      ActiveRecord::Base.establish_connection(CONFIGURATIONS[:sqlite3])

      @database = CONFIGURATIONS[:sqlite3][:database]
      #ActiveRecord::Base.connection.drop_database(@database)
      #ActiveRecord::Base.connection.create_database(@database)
      ActiveRecord::Base.connection.reset!

      FactoryHelpers::CreateCollection.up
    end
  end


end
