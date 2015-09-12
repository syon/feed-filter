source "https://rubygems.org"
ruby "2.2.2"

gem 'sinatra'
gem 'sinatra-contrib'
gem 'unicorn'
gem 'slim'

gem 'sinatra-activerecord'
gem 'activerecord'
gem 'rake'
gem 'pg'

group :development, :test do
  # sqlite3 is not supported on Heroku.
  gem 'sqlite3'
end

puts "=== Gemfile ==="
p ENV['RACK_ENV']
puts "=== Gemfile ==="
