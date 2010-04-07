module Foreigner
  module SchemaDumper
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        alias_method_chain :tables, :foreign_keys
      end
    end
    
    module InstanceMethods
      def tables_with_foreign_keys(stream)
        tables_without_foreign_keys(stream)
        @connection.tables.sort.each do |table|
          next unless foreign_keys = @connection.foreign_keys(table)
          stream.puts generate_foreign_keys_statements(foreign_keys).join("\n")
        end
      end
      
      private

      # Generates a string for a given list of ForeignKeyDefinition
      # Has no concept of streams or connections, so this can be tested in isolation.
      def generate_foreign_keys_statements(foreign_keys)
        decorator = [
        # [ :option_name, lambda { |fk| filter } ],
          [ :name,        lambda { |fk| fk.options[:name] } ],
          [ :column,      lambda { |fk| fk.options[:column] && fk.options[:column] != "#{fk.to_table.singularize}_id" } ],
          [ :primary_key, lambda { |fk| fk.options[:primary_key] && fk.options[:primary_key] != 'id' } ],
          [ :dependent,   lambda { |fk| fk.options[:dependent].present? } ]
        ] 

        foreign_keys.map do |foreign_key|
          statement_parts = [[ ' ', 'add_foreign_key', foreign_key.from_table.to_sym.inspect].join(' ') ]
          statement_parts << foreign_key.to_table.to_sym.inspect

          if foreign_key.options
            statement_parts << decorator.map do |option, guard|
              [ ':', option, ' => ', foreign_key.options[option].inspect ].join if guard.call(foreign_key)
            end - [nil]
          end
          '  ' + statement_parts.join(', ')
        end
      end
    end # InstanceMethods

  end
end
