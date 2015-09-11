ENV['RACK_ENV'] = "development" if ENV['RACK_ENV'].nil?
puts "ENV['RACK_ENV']: #{ENV['RACK_ENV']}"

ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read('config/database.yml')).result)
ActiveRecord::Base.establish_connection(ENV['RACK_ENV'].to_sym)
use ActiveRecord::ConnectionAdapters::ConnectionManagement # for Connection Error

class Feeds < ActiveRecord::Base
end
