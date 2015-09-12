require 'active_record'
require 'erb'

ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read('config/database.yml')).result)
ActiveRecord::Base.establish_connection(:development)

class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.integer :feed_id
      t.string :feed_url
      t.text :filter_rules
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :feeds
  end
end

CreateFeeds.new.up
