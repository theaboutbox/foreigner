
require 'rubygems'

require 'active_support'
require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'active_record/connection_adapters/mysql_adapter'
require 'foreigner'
require "foreigner/connection_adapters/postgresql_adapter"
require "foreigner/connection_adapters/mysql_adapter"
require "foreigner/connection_adapters/sqlite3_adapter"

require File.expand_path('factory_helper.rb', File.dirname(__FILE__))
require File.expand_path('adapter_helper.rb', File.dirname(__FILE__))

CONFIGURATIONS = {
  :postgresql => {
    :adapter => "postgresql",
    :username => "root",
    :password => "",
    :database => "test_foreigner_gem",
    :min_messages => "ERROR"
  },
  :postgresql_admin => {
    :adapter => "postgresql",
    :username => "root",
    :password => "",
    :database => "test",
    :min_messages => "ERROR"
  }, # :postgresql_admin is used to connect in; :postgresql is used to actually test the migrations
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

# Turn this on for debugging
ActiveRecord::Migration.verbose = false


