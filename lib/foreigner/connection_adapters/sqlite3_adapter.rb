require 'foreigner/connection_adapters/sql_2003'

module Foreigner
  module ConnectionAdapters
    module SQLite3Adapter
      include Foreigner::ConnectionAdapters::Sql2003

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
    module TableDefinition
      class ForeignKey < Struct.new(:base, :to_table, :options)

        def to_sql
          base.foreign_key_definition(to_table, options)
        end
        alias to_s :to_sql
      end

      def self.included(base)
        base.class_eval do
          include InstanceMethods
        end
      end

      module InstanceMethods
        # Adds a :foreign_key option to TableDefinition.references.
        # If :foreign_key is true, a foreign key constraint is added to the table.
        # You can also specify a hash, which is passed as foreign key options.
        #
        # ===== Examples
        # ====== Add goat_id column and a foreign key to the goats table.
        #  t.references(:goat, :foreign_key => true)
        # ====== Add goat_id column and a cascading foreign key to the goats table.
        #  t.references(:goat, :foreign_key => {:dependent => :delete})
        #
        # Note: No foreign key is created if :polymorphic => true is used.
        def references_with_foreign_keys(*args)
          options = args.extract_options!
          fk_options = options.delete(:foreign_key)

          if fk_options && !options[:polymorphic]
            fk_options = {} if fk_options == true
            args.each { |to_table| foreign_key(to_table, fk_options) }
          end

          references_without_foreign_keys(*(args << options))
        end

        # Defines a foreign key for the table. +to_table+ can be a single Symbol, or
        # an Array of Symbols.
        #
        # ===== Examples
        # ====== Creating a simple foreign key
        #  t.foreign_key(:people)
        # ====== Defining the column
        #  t.foreign_key(:people, :column => :sender_id)
        # ====== Specify cascading foreign key
        #  t.foreign_key(:people, :dependent => :delete)
        def foreign_key(to_table, options = {})
          if @base.supports_foreign_keys?
            to_table = to_table.to_s.pluralize if ActiveRecord::Base.pluralize_table_names
            foreign_keys << ForeignKey.new(@base, to_table, options)
          end
        end
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

