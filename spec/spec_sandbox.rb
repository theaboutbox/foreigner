# Cribbed from http://github.com/pluginaweek/plugin_test_helper
# Make sure our default RAILS_ROOT from the helper plugin is in the load path
RAILS_SANDBOX_VERSION = '2.3.5'
HELPER_RAILS_ROOT = File.expand_path('../spec/app_root/rails-' + RAILS_SANDBOX_VERSION, File.dirname(__FILE__)) unless defined?(HELPER_RAILS_ROOT)
$:.unshift(HELPER_RAILS_ROOT)  

# Determine the plugin's root test directory and add it to the load path
RAILS_ROOT = HELPER_RAILS_ROOT # NOTE: Tagged for cleanup
$:.unshift(RAILS_ROOT)

# Set the default environment to sqlite3's in_memory database
ENV['RAILS_ENV'] ||= 'test_postgresql'
# Available for testing:
#   test_sqlite3
#   test_mysql
#   test_postgresql

# First boot the Rails framework
require 'config/boot'          

# Extend it so that we can hook into the configuration process
require 'spec/configuration_helper'

# Load the Rails environment and testing framework
require 'config/environment'
#require 'test_help'

# Undo changes to RAILS_ENV
silence_warnings {RAILS_ENV = ENV['RAILS_ENV']}

