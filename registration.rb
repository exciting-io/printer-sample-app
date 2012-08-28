require "data_mapper"

# If you use postgres, you'll be able to deploy to Heroku easily.
# Otherwise, change this if you like.
#
# To create a local postgres database, run `createdb printer-sample-app`
DataMapper::setup(:default, ENV['SHARED_DATABASE_URL'] || "postgres://localhost/printer-sample-app")

class Registration
  include DataMapper::Resource
  property :id, Serial
  property :print_url, String, length: 255, unique: true,
           messages: {
             is_unique: "It looks like this printer is already registered."
           }

  # Add any other attributes you might want to store, for
  # example any usernames, email addresses, tokens or other
  # parameters that could influence the content posted to the printer
end

# Perform basic sanity checks and initialize all relationships
DataMapper.finalize
Registration.auto_upgrade!
