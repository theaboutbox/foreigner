# If you want to change the default rails environment
# ENV['RAILS_ENV'] ||= 'your_env'

# Load the plugin testing framework
require 'rubygems'
require 'plugin_test_helper'

# Run the migrations (optional)
# ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/test_case'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'active_record/connection_adapters/mysql_adapter'
require 'foreigner'

