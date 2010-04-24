# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_smoketest_session',
  :secret      => '256d2fba814e6105df462f3d5713221031faf5c175ec4b3cd012ecb7d7fc41f1678b2ad75dcca300e4aca15b1cbd3cdca80827e0440d2b80e40cfe405034a67e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
