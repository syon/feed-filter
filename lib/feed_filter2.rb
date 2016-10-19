require_relative 'filter_factory'

class FeedFilter2

  attr_accessor :charset
  attr_accessor :content

  def prepare_one(feed_id)
    feed = Feeds.where(:feed_id => feed_id.to_i).first
    if feed
      feed.fetched_at = Time.now
      feed.save!
    end
    @content = get_filtered_content(feed)
  end

  def get_filtered_content(feed)
    fetch_feed_and_filter(feed.feed_url, feed.filter_rules)

    formatter = REXML::Formatters::Default.new
    result = formatter.write(@doc.root, '')
    @doc.xml_decl.to_s + "\n" + result
  end

  def get_recent_feeds(ids)
    Feeds.where(:feed_id => ids)
  end

  private

    def fetch_feed_and_filter(feed_url, filter_rules)
      uri = open(feed_url, "User-Agent" => "Safari/601.1")
      @doc = REXML::Document.new(uri.read)
      @charset = @doc.xml_decl.encoding
      fac = FilterFactory.new(@doc, feed_url, filter_rules)
      fac.filtering
    end

end
