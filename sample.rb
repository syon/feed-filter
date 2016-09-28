require 'rexml/document'
require 'open-uri'
require 'awesome_print'


def get_entries(doc)
  case doc.root.name.downcase
  when "rdf"
    puts "--------- RSS 1.0"
    return doc.get_elements('//item')
  when "rss"
    puts "--------- RSS 2.0"
    return doc.get_elements('//item')
  when "feed"
    puts "--------- Atom"
    return doc.get_elements('//entry')
  end
end

feed_url = "http://feeds.feedburner.com/hatena/b/hotentry"
doc = REXML::Document.new(open(feed_url).read)

ap doc.root.name
ap doc.root.attribute 'xmlns'

entries = get_entries(doc)
ap entries

first = entries.first
ap first.methods
