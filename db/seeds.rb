require "yaml"

Feeds.delete_all

feeds = YAML.load_file 'db/seeds_data/feeds.yml'
feeds.each do |f|
  puts "Creating... (feed_id: #{f["feed_id"]})"
  Feeds.create(
    :feed_id => f["feed_id"],
    :feed_url => f["feed_url"],
    :filter_rules => f["filter_rules"],
    :secret => f["secret"],
    :fetched_at => f["fetched_at"]
  )
end

puts "Feeds.count #{Feeds.count}"
