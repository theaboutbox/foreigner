module Foreigner
  module SchemaDumper
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        alias_method_chain :tables, :foreign_keys
        alias_method_chain :table,  :foreign_keys
      end
    end

    module InstanceMethods
      def tables_with_foreign_keys(stream)
        tables_without_foreign_keys(stream)
        if @connection.class != ActiveRecord::ConnectionAdapters::SQLite3Adapter
          @connection.tables.sort.each do |table|
            foreign_keys(table, stream)
          end
        end
      end

      def table_with_foreign_keys(table, stream)
        if @connection.class == ActiveRecord::ConnectionAdapters::SQLite3Adapter
          foreign_key_table(table, stream)
        else
          table_without_foreign_keys(table, stream)
        end
      end

      private
        def foreign_keys(table_name, stream)
          if (foreign_keys = @connection.foreign_keys(table_name)).any?
            add_foreign_key_statements = foreign_keys.map do |foreign_key|
              statement_parts = [ ('add_foreign_key ' + foreign_key.from_table.inspect) ]
              statement_parts << foreign_key.to_table.inspect
              statement_parts << (':name => ' + foreign_key.options[:name].inspect)

              if foreign_key.options[:column] != "#{foreign_key.to_table.singularize}_id"
                statement_parts << (':column => ' + foreign_key.options[:column].inspect)
              end
              if foreign_key.options[:primary_key] != 'id'
                statement_parts << (':primary_key => ' + foreign_key.options[:primary_key].inspect)
              end
              if foreign_key.options[:dependent].present?
                statement_parts << (':dependent => ' + foreign_key.options[:dependent].inspect)
              end

              '  ' + statement_parts.join(', ')
            end

            stream.puts add_foreign_key_statements.sort.join("\n")
            stream.puts
          end
        end

        # This is almost direct copy from
        # active_record/schema.dumper with the add_foreign_keys method
        # inserted into the middle
        def foreign_key_table(table, stream)
          columns = @connection.columns(table)
          begin
            tbl = StringIO.new

            # first dump primary key column
            if @connection.respond_to?(:pk_and_sequence_for)
              pk, pk_seq = @connection.pk_and_sequence_for(table)
            elsif @connection.respond_to?(:primary_key)
              pk = @connection.primary_key(table)
            end
            pk ||= 'id'

            tbl.print "  create_table #{table.inspect}"
            if columns.detect { |c| c.name == pk }
              if pk != 'id'
                tbl.print %Q(, :primary_key => "#{pk}")
              end
            else
              tbl.print ", :id => false"
            end
            tbl.print ", :force => true"
            tbl.puts " do |t|"

            # then dump all non-primary key columns
            column_specs = columns.map do |column|
              raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" if @types[column.type].nil?
              next if column.name == pk
              spec = {}
              spec[:name]      = column.name.inspect
              spec[:type]      = column.type.to_s
              spec[:limit]     = column.limit.inspect if column.limit != @types[column.type][:limit] && column.type != :decimal
              spec[:precision] = column.precision.inspect if !column.precision.nil?
              spec[:scale]     = column.scale.inspect if !column.scale.nil?
              spec[:null]      = 'false' if !column.null
              spec[:default]   = default_string(column.default) if column.has_default?
              (spec.keys - [:name, :type]).each{ |k| spec[k].insert(0, "#{k.inspect} => ")}
              spec
            end.compact

            # find all migration keys used in this table
            keys = [:name, :limit, :precision, :scale, :default, :null] & column_specs.map(&:keys).flatten

            # figure out the lengths for each column based on above keys
            lengths = keys.map{ |key| column_specs.map{ |spec| spec[key] ? spec[key].length + 2 : 0 }.max }

            # the string we're going to sprintf our values against, with standardized column widths
            format_string = lengths.map{ |len| "%-#{len}s" }

            # find the max length for the 'type' column, which is special
            type_length = column_specs.map{ |column| column[:type].length }.max

            # add column type definition to our format string
            format_string.unshift "    t.%-#{type_length}s "

            format_string *= ''

            column_specs.each do |colspec|
              values = keys.zip(lengths).map{ |key, len| colspec.key?(key) ? colspec[key] + ", " : " " * len }
              values.unshift colspec[:type]
              tbl.print((format_string % values).gsub(/,\s*$/, ''))
              tbl.puts
            end

            # add the foreign keys
            add_foreign_keys(table, tbl)

            tbl.puts "  end"
            tbl.puts

            indexes(table, tbl)

            tbl.rewind
            stream.print tbl.read
          rescue => e
            stream.puts "# Could not dump table #{table.inspect} because of following #{e.class}"
            stream.puts "#   #{e.message}"
            stream.puts
          end

          stream
        end

        def add_foreign_keys(table_name, stream)
          if (foreign_keys = @connection.foreign_keys(table_name)).any?
            add_foreign_key_statements = foreign_keys.map do |foreign_key|
              statement_parts = ["  t.foreign_key " + foreign_key.to_table.inspect]
              statement_parts << (':column => ' + foreign_key.options[:column].inspect)
              statement_parts << (':dependent => ' + foreign_key.options[:dependent].inspect)
              '  ' + statement_parts.join(', ')
            end

            stream.puts add_foreign_key_statements.sort.join("\n")
          end
        end
    end
  end
end

