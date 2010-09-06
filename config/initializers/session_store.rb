# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_bionic_cms_session',
  :secret => '259228fe44741a481f04c91838c2a30dce5aa389a9b258a73a5b503ef436b8fe7410c30c25f1695d8b15d66185e9c09de2b69852bd7a0319a9583965d098c32e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store