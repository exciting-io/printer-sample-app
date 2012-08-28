require "data_mapper"

# If you use PostgreSQL, you'll be able to deploy to Heroku easily.
# Otherwise, change this if you like.
#
# To create a local PostgreSQL database, run `createdb printer-sample-app`
database_url = ENV['SHARED_DATABASE_URL'] || "postgres://localhost/printer-sample-app"
DataMapper::setup(:default, database_url)

class Registration
  include DataMapper::Resource
  property :id, Serial
  property :print_url, String, length: 255, unique: true,
           messages: {
             is_unique: "It looks like this printer is already registered."
           }

  # FIXME: Add any other attributes you might want to store, for
  # example any usernames, email addresses, tokens or other
  # parameters that could influence the content posted to the printer
  #
  # For example, if you're printing something location-specific, you
  # might want to ask the user for their location when they are signing up,
  # and store it here against their print url.
end

# Perform basic sanity checks and initialize all relationships
DataMapper.finalize
Registration.auto_upgrade!
