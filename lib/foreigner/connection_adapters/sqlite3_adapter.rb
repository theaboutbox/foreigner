require 'foreigner/semantics/sql_2003'

module Foreigner
  module ConnectionAdapters
    module SQLite3Adapter
      include Foreigner::Semantics::Sql2003

      def foreign_keys(table_name)
        foreign_keys = []
        create_table_info = select_value %{
SELECT sql
FROM sqlite_master
WHERE sql LIKE '%FOREIGN KEY%'
AND name = '#{table_name}'
}
      unless create_table_info.nil?
        fk_columns = create_table_info.scan(/FOREIGN KEY\s*\(\"([^\"]+)\"\)/)
        fk_tables = create_table_info.scan(/REFERENCES\s*\"([^\"]+)\"/)
        fk_references = create_table_info.scan(/REFERENCES[^\,]+/)
        if fk_columns.size == fk_tables.size && fk_references.size == fk_columns.size
          fk_columns.each_with_index do |fk_column, index|
            if fk_references[index] =~ /ON DELETE CASCADE/
              fk_references[index] = :delete
            elsif fk_references[index] =~ /ON DELETE SET NULL/
              fk_references[index] = :nullify
            else
              fk_references[index] = nil
            end
            foreign_keys << ForeignKeyDefinition.new(table_name, fk_tables[index][0], :column => fk_column[0], :dependent => fk_references[index])
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
    SQLite3Adapter.class_eval do
      include Foreigner::ConnectionAdapters::SQLite3Adapter
    end
  end
end

