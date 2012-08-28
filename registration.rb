require "data_mapper"

# If you use PostgreSQL, you'll be able to deploy to Heroku easily.
# Otherwise, change this if you like.
#
# To create a local PostgreSQL database, run `createdb printer-sample-app`
database_url = ENV['DATABASE_URL'] || "postgres://localhost/printer-sample-app"
DataMapper::setup(:default, database_url)

class TokenPair
  include DataMapper::Resource

  belongs_to :registration

  property :id, Serial
  property :refresh_token, Text
  property :access_token, Text
  property :expires_in, Integer
  property :issued_at, Integer

  def update_token!(object)
    self.refresh_token = object.refresh_token
    self.access_token = object.access_token
    self.expires_in = object.expires_in
    self.issued_at = object.issued_at
  end

  def to_hash
    {
      :refresh_token => refresh_token,
      :access_token => access_token,
      :expires_in => expires_in,
      :issued_at => Time.at(issued_at)
    }
  end
end

class Registration
  include DataMapper::Resource
  property :id, Serial
  property :print_url, String, length: 255, unique: true,
           messages: {
             is_unique: "It looks like this printer is already registered."
           }

  has 1, :token_pair
end

# Perform basic sanity checks and initialize all relationships
DataMapper.finalize
Registration.auto_upgrade!
TokenPair.auto_upgrade!
