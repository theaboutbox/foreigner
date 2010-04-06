begin
    require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
    puts "You need to install rspec in your base app"
      exit
end

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

# Load the plugin testing framework
require 'rubygems'
# require 'plugin_test_helper'
#
# # Run the migrations (optional)
# # ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/test_case'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'active_record/connection_adapters/mysql_adapter'
require 'foreigner'


