#ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

# Load the plugin testing framework
require 'rubygems'
require File.expand_path('../spec/spec_sandbox', File.dirname(__FILE__))

# require 'plugin_test_helper'
#
# # Run the migrations (optional)
# # ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

require 'active_support'
require 'active_record'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'active_record/connection_adapters/mysql_adapter'
require 'foreigner'


