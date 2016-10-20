require 'uri'
require_relative 'filter_factory'

class FeedFilter

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

  def fetch_feed(feed_id)
    @feed = Feeds.where(:feed_id => feed_id.to_i).first
    if @feed
      @feed.fetched_at = Time.now
      @feed.save!
    end
    @feed
  end

  def view_filtered_titles()
    fetch_feed_and_filter(@feed.feed_url, @feed.filter_rules, true)
    titles = []
    FilterFactory.get_entries(@doc).each do |el|
      titles << el.elements['title'].text
    end
    titles
  end

  def preview_filtered_titles(params)
    @feed = create(params)
    fetch_feed_and_filter(@feed.feed_url, @feed.filter_rules, true)
    @feed.destroy

    items = []
    entries = FilterFactory.get_entries(@doc)
    entries.each do |el|
      item = {}
      item[:title] = el.elements['title'].text
      item[:url] = FilterFactory.clean_url(el)
      items << item
    end
    items
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

  def update(params)
    feed = Feeds.where(:feed_id => params[:feed_id].to_i).first
    if feed.secret.present?
      unless feed.secret == params[:secret]
        puts "Secret unmatched."
        return feed
      end
    end
    args = make_feed_args(params)
    feed.feed_url = args[:f_url]
    feed.filter_rules = args[:f_rules]
    feed.save!
    feed
  end

  def delete(params)
    feed_id = params[:feed_id]
    feed = Feeds.where(:feed_id => feed_id.to_i).first
    if feed.secret
      unless feed.secret == params[:secret]
        puts "Secret unmatched."
        return feed
      end
    end
    feed.destroy
  end

  private

    def fetch_feed_and_filter(feed_url, filter_rules, is_preview=false)
      ap "-- fetch_feed_and_filter ------"
      ap feed_url.class?
      uri = open(feed_url, "User-Agent" => "Safari/601.1")
      @doc = FilterFactory.make_doc(uri.read)
      @charset = @doc.xml_decl.encoding
      fac = FilterFactory.new(@doc, feed_url, filter_rules)
      fac.filtering(is_preview)
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
