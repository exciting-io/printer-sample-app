# This task can be run by CRON, or Heroku's Scheduler addon, to dispatch
# content to printers.

task :run do
  $LOAD_PATH.unshift File.dirname(__FILE__)
  require "registration"
  require "net/http"
  require "uri"
  puts "Running..."

  APP_URL = ENV["APP_URL"]

  Registration.each do |registration|
    puts "Processing job #{registration.id}: #{registration.print_url}"
    Net::HTTP.post_form(URI.parse(registration.print_url), url: "#{APP_URL}/content/#{registration.id}")
  end
end
