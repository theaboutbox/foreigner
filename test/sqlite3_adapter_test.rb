require File.dirname(__FILE__) + '/test_helper'
require "foreigner/connection_adapters/sqlite3_adapter"

require "ruby-debug"

class SQLite3AdapterTest < ActiveRecord::TestCase

  # see the migration files under app_root/db/migrate for more details

  def test_adding_cows_to_the_farm_with_t_dot_foreign_key_farms
    table = "cows"
    migrate(table)
    assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\)/, schema(table))
  end

  def test_adding_pigs_to_the_farm_with_t_dot_references_farms_foreign_key_true
    table = "pigs"
    migrate(table)
    assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\)/, schema(table))
  end

  private
    def setup_test
      CreateFarms.up
    end

    def schema(table_name)
      ActiveRecord::Base.connection.select_value %{
        SELECT sql
        FROM sqlite_master
        WHERE name = '#{table_name}'
      }
    end

    def migrate(table_name)
      migration = "create_#{table_name}"
      require "app_root/db/migrate/#{migration}"
      migration.camelcase.constantize.up
      assert ActiveRecord::Base.connection.table_exists?(table_name)
    end
end

