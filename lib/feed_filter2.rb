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

  def create(params)
    args = make_feed_args(params)
    Feeds.create(
      :feed_id => args[:f_id],
      :feed_url => args[:f_url],
      :filter_rules => args[:f_rules],
      :secret => args[:secret]
    )
  end

  private

    def fetch_feed_and_filter(feed_url, filter_rules)
      uri = open(feed_url, "User-Agent" => "Safari/601.1")
      @doc = REXML::Document.new(uri.read)
      @charset = @doc.xml_decl.encoding
      fac = FilterFactory.new(@doc, feed_url, filter_rules)
      fac.filtering
    end

    def make_feed_args(params)
      {
        f_id: Time.now.to_i,
        f_url: params[:feed_url],
        f_rules: {
          mute: {
            title: make_compact(params[:"mute.title"]),
            domain: make_compact(params[:"mute.domain"]),
            url_prefix: make_compact(params[:"mute.url_prefix"])
          }
        },
        secret: params[:secret]
      }
    end

    def make_compact(arr)
      unless arr.blank?
        arr = arr.reject(&:blank?)
      end
      arr
    end

end
