require "rubygems"
require "bundler/setup"
require "sinatra"
$LOAD_PATH.unshift File.dirname(__FILE__)
require "registration"
require "google/api_client"

use Rack::Session::Pool, :expire_after => 86400 # 1 day

get "/" do
  erb :index
end

get "/register" do
  @registration = Registration.new
  erb :register
end

post "/register" do
  @registration = Registration.new(params[:registration])
  if @registration.save
    session[:registration_id] = @registration.id
    redirect "/oauth2authorize"
  else
    @errors = @registration.errors
    erb :register
  end
end

get "/registered" do
  erb :registered
end

get "/content/:registration_id" do
  registration = Registration.get(params[:registration_id])

  client = google_client(registration.token_pair)
  tasks_api = client.discovered_api('tasks')

  all_lists = client.execute(tasks_api.tasklists.list, {'userId' => '@me'}).data.items
  @tasks = all_lists.map do |list|
    t = client.execute(tasks_api.tasks.list, {'userId' => '@me', 'tasklist' => list.id})
    t.data.items.select { |x| x.status == "needsAction" && x.title != "" }.map { |x| x.title }
  end.flatten

  erb :content
end


# Google OAuth2 stuff

def google_client(token_pair=nil, code=nil)
  client = Google::APIClient.new
  client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
  client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
  client.authorization.scope = 'https://www.googleapis.com/auth/tasks'
  client.authorization.redirect_uri = to('/oauth2callback')
  client.authorization.code = code if code
  if token_pair
    client.authorization.update_token!(token_pair.to_hash)
  end
  if client.authorization.refresh_token && client.authorization.expired?
    client.authorization.fetch_access_token!
  end
  client
end

get '/oauth2authorize' do
  client = google_client(nil)
  redirect client.authorization.authorization_uri.to_s, 303
end

get '/oauth2callback' do
  client = google_client(nil, params[:code])
  client.authorization.fetch_access_token!

  registration = Registration.get(session[:registration_id])
  token_pair = registration.token_pair || TokenPair.new

  token_pair.update_token!(client.authorization)
  token_pair.registration = registration
  token_pair.save!

  redirect '/registered'
end
