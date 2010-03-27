require File.dirname(__FILE__) + '/test_helper'
require "foreigner/connection_adapters/sqlite3_adapter"

require "ruby-debug"

class SQLite3AdapterTest < ActiveRecord::TestCase

  # see the migration files under app_root/db/migrate for more details

  # t.foreign_key :farm
  def test_adding_cows_to_the_farm_with_t_dot_foreign_key_farm
    premigrate
    table = "cows"
    migrate table
    assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\)/, schema(table))
  end

  # t.foreign_key :farm, :column => :shearing_farm_id
  def test_adding_sheep_to_the_farm_with_t_dot_foreign_key_farm_column_id_shearing_farm_id
    premigrate
    table = "sheep"
    migrate table
    assert_match(/FOREIGN KEY \(\"shearing_farm_id\"\) REFERENCES \"farms\"\(id\)/, schema(table))
  end

  # t.foreign_key :farm, :dependent => :nullify
  def test_adding_bears_to_the_farm_with_t_dot_foreign_key_farm_dependent_nullify
    premigrate
    table = "bears"
    migrate table
    assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\) ON DELETE SET NULL/, schema(table))
  end

  # t.foreign_key :farm, :dependent => :delete
  def test_adding_elephants_to_the_farm_with_t_dot_foreign_key_farm_dependent_delete
    premigrate
    table = "elephants"
    migrate table
    assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\) ON DELETE CASCADE/, schema(table))
  end

  # add assertions to test schema_dumper

  # then in mysql_adapter_test
  # add the same tests for mysql to see if we get foreign_keys on the table definition
  # too hard to test? see the guide you downloaded

  # t.references :farm, :foreign_key => :true
  def test_adding_pigs_to_the_farm_with_t_dot_references_farm_foreign_key_true
    premigrate
    table = "pigs"
    migrate table
    assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\)/, schema(table))
  end

  # t.references :farm, :foreign_key => {:dependent => :nullify}
  def test_adding_tigers_to_the_farm_with_t_dot_references_farm_foreign_key_dependent_delete
    premigrate
    table = "tigers"
    migrate table
    assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\) ON DELETE SET NULL/, schema(table))
  end

  # t.references :farm, :foreign_key => {:dependent => :delete}
  def test_adding_goats_to_the_farm_with_t_dot_references_farm_foreign_key_dependent_delete
    premigrate
    table = "goats"
    migrate table
    assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\) ON DELETE CASCADE/, schema(table))
  end

  private

    def premigrate
      migrate "farms"
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

