require "rubygems"
require "bundler/setup"
require "sinatra"
$LOAD_PATH.unshift File.dirname(__FILE__)
require "registration"
require "sudoku"

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
    erb :registered
  else
    @errors = @registration.errors
    erb :register
  end
end

get "/content/:registration_id" do
  @sudoku_number = rand(SUDOKU_STRINGS.length)
  @sudoku = sudoku(@sudoku_number)
  erb :sudoku
end
