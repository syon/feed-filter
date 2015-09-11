require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'active_record'
require 'slim'
require_relative 'app.rb'
require_relative 'ar_env.rb'

run Sinatra::Application
