require "rubygems"
require "bundler/setup"

$LOAD_PATH.unshift(".")
require "app"

# Use sass
require 'sass/plugin/rack'
Sass::Plugin.options[:template_location] = 'public/stylesheets'
use Sass::Plugin::Rack

run Sinatra::Application
