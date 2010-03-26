require 'foreigner/connection_adapters/abstract/schema_statements'
require 'foreigner/connection_adapters/abstract/schema_definitions'
require 'foreigner/connection_adapters/sql_2003'
require 'foreigner/schema_dumper'

module Foreigner
  mattr_accessor :adapters
  self.adapters = {}

  class << self
    def register(adapter_name, file_name)
      adapters[adapter_name] = file_name
    end

    def load_adapter!(adapter_name)
      if adapters.key?(adapter_name)
        require adapters[adapter_name]
      end
    end

    def autoload
      load_adapter! ActiveRecord::Base.connection_pool.spec.config[:adapter].downcase
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    include Foreigner::ConnectionAdapters::SchemaStatements
    include Foreigner::ConnectionAdapters::SchemaDefinitions
  end

  SchemaDumper.class_eval do
    include Foreigner::SchemaDumper
  end
end

Foreigner.register 'mysql', 'foreigner/connection_adapters/mysql_adapter'
Foreigner.register 'postgresql', 'foreigner/connection_adapters/postgresql_adapter'
Foreigner.register 'sqlite3', 'foreigner/connection_adapters/sqlite3_adapter'

