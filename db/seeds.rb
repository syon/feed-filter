# coding: utf-8
require "csv"

Feeds.delete_all
CSV.foreach('db/seeds_data/feeds.csv') do |row|
  Feeds.create(:feed_id => row[0], :feed_url => row[1], :filter_rules => row[2])
end
puts "Feeds.count #{Feeds.count}"
