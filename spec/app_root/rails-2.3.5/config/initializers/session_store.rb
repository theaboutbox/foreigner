# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails-2.3.5_session',
  :secret      => '4c3daa432bac42ebaab90a09d39403299e692b8b2614a4641c7423a3c414501bdc42cbccbca61772f698b03815815549b9b031478d35cd72b2e65a107faa6fd4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
