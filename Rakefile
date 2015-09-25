if ENV['RACK_ENV'].nil?
  puts "Dotenv Loading..."
  require 'dotenv'
  Dotenv.load
end

require 'sinatra'
require 'active_record'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require_relative 'ar_env.rb'
