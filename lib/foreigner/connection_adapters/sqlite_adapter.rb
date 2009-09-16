require 'foreigner/connection_adapters/sql_2003'

module Foreigner
  module ConnectionAdapters
    module SQLiteAdapter
      include Foreigner::ConnectionAdapters::Sql2003

      def foreign_keys(table_name)
        foreign_keys = []
        create_table_info = select_value %{
SELECT sql
FROM sqlite_master
WHERE sql LIKE '%FOREIGN KEY%'
AND name = '#{table_name}'
}
      if !create_table_info.nil?
        fk_columns = create_table_info.scan(/FOREIGN KEY\s*\(\"([^\"]+)\"\)/)
        fk_tables = create_table_info.scan(/REFERENCES\s*\"([^\"]+)\"/)
        if fk_columns.size == fk_tables.size
          fk_columns.each_with_index do |fk_column, index|
            foreign_keys << ForeignKeyDefinition.new(table_name, fk_tables[index][0], :column => fk_column[0])
          end
        end
      end
      foreign_keys
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    SQLiteAdapter.class_eval do
      include Foreigner::ConnectionAdapters::SQLiteAdapter
    end
  end
end

