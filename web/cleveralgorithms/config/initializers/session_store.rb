# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cleveralgorithms_session',
  :secret      => 'eac17a9da67ecf837b194e8031ceaf1973ca2729782897afbb35eda7587b6f40c07c8f805665f6037a1fd3ccafe44a123dcb88a434057df07f310aacb677a098'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
