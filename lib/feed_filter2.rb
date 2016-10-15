class FeedFilter2

  attr_accessor :charset
  attr_accessor :content

  def initialize(feed_id)
    feed = Feeds.where(:feed_id => feed_id.to_i).first
    if feed
      feed.fetched_at = Time.now
      feed.save!
    end
    @content = get_filtered_content(feed)
  end

  def get_filtered_content(feed)
    filtering(feed.feed_url, feed.filter_rules)

    formatter = REXML::Formatters::Default.new
    result = formatter.write(@doc.root, '')
    @doc.xml_decl.to_s + "\n" + result
  end

  def filtering(feed_url, filter_rules)
    uri = open(feed_url, "User-Agent" => "Safari/601.1")
    @doc = REXML::Document.new(uri.read)
    @charset = @doc.xml_decl.encoding
    ## filter_rules
  end

end
