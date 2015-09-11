require 'active_record'

ActiveRecord::Base.establish_connection(
    "adapter"=>"sqlite3",
    "database" => "db/development.sqlite3"
)

class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.integer :feed_id
      t.timestamps
    end
  end

  def self.down
    drop_table :feeds
  end
end

CreateFeeds.new.up 
