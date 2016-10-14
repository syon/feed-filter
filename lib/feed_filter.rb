require 'rexml/document'
require 'open-uri'
require 'active_support/core_ext'
require 'ap'

class FeedFilter

  attr_accessor :charset

  def initialize()
  end

  def fetch_feed(feed_id)
    @feed = Feeds.where(:feed_id => feed_id.to_i).first
    if @feed
      @feed.fetched_at = Time.now
      @feed.save!
    end
    @feed
  end

  def create(params)
    p params
    args = make_feed_args(params)
    p args
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

  def view_filtered_titles()
    filtering({preview: true})
    titles = []
    get_entries(@doc).each do |el|
      titles << el.elements['title'].text
    end
    titles
  end

  def preview_filtered_titles(params)
    @feed = create(params)
    filtering({preview: true})
    @feed.destroy

    items = []
    entries = get_entries(@doc)
    entries.each do |el|
      item = {}
      item[:title] = el.elements['title'].text
      item[:url] = clean_url(el)
      items << item
    end
    items
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

  def get_filtered_content()
    filtering()

    formatter = REXML::Formatters::Default.new
    result = formatter.write(@doc.root, '')
    @doc.xml_decl.to_s + "\n" + result
  end

  def filtering(option = {})
    @feed_url = @feed.feed_url
    uri = open(@feed_url, "User-Agent" => "Safari/601.1")
    @doc = REXML::Document.new(uri.read)
    @charset = @doc.xml_decl.encoding
    @rules = @feed.filter_rules
    @debug = option[:preview]

    entries = get_entries(@doc)
    entries.each do |el|
      url = clean_url(el)
      title = get_title(el, url)
      ctt = get_content(el)

      if is_ng_title(title)
        delete_element(el)
      end

      if is_ng_domain(url)
        delete_element(el)
      end

      if is_ng_urlprefix(url)
        delete_element(el)
      end

      clean_invalid_content(ctt)

      if @feed_url.include?("hotentry")
        edit_hotentry(ctt, el)
      else
        append_hatebu_count(url, ctt)
      end

      append_hatebu_iframe(url, ctt)
    end

    # show_all_titles()
  end

  def get_title(el, url)
    title = el.elements['title'].text
    if url.match(%r{https?://anond.hatelabo.jp})
      title << " :: anond"
    end
    el.elements['title'].text = title
    title
  end

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

  def clean_url(el)
    url = el.elements['link'].text
    url = el.elements['link'].attribute('href').to_s unless url
    url.gsub! %r{\?ncid=rss_truncated}, ""
    el.elements['link'].text = url
    url
  end

  def edit_hotentry(ctt, el)
    d = parse_hotentery(ctt.text, el)
    # ap "[S] #{ctt.object_id}"
    ctt = REXML::CData.new(%(
      <![CDATA[
        #{d[:heroimg]}
        <p>#{d[:favicon]} #{d[:hbcount]}</p>
        <p>#{d[:desc]}</p>
      ]]>
    ))
    # ap "[E] #{ctt.object_id}"
  end

  def parse_hotentery(ctt, el)
    # Hero Image
    heroimg = ""
    heroimg_mch = ctt.match(%r{<img src="(http://cdn-ak.b.st-hatena.com/entryimage/.*?.jpg)" .*? class="entry-image" />}i)
    if heroimg_mch
      heroimg_url = heroimg_mch[1]
      heroimg = %(<img src="#{heroimg_url}">)
    end

    # Favicon
    favicon = ""
    favicon_mch = ctt.match(%r{<img src="(http://cdn-ak.favicon.st-hatena.com.*?)".*?/>}i)
    if favicon_mch
      favicon_url = favicon_mch[1]
      favicon = %(<img src="#{favicon_url}">)
    end

    # Hatebu Count Image
    hbcount = ""
    hbcount_mch = ctt.match(%r{<img src="(http://b.hatena.ne.jp/entry/image/http.*?)".*?/>}i)
    if hbcount_mch
      hbcount_url = hbcount_mch[1]
      hbcount = %(<img src="#{hbcount_url}">)
    end

    # Result
    {
      heroimg: heroimg,
      favicon: favicon,
      hbcount: hbcount,
      desc: el.elements['description'].text
    }
  end

  def clean_invalid_content(ctt)
    return nil unless ctt
    return nil unless ctt.text
    ctt.text.gsub! %r{<img [^<]*? width="1".*?/>}, "" if ctt
    ctt.text.gsub! %r{<[^<]*?\.\.\.$}, "" if ctt
  end

  def append_hatebu_count(url, ctt)
    return nil unless ctt
    return nil unless ctt.text
    cntimg = %{<cite><img src="http://b.hatena.ne.jp/entry/image/#{url}" /></cite>}
    ctt.text.gsub! %r{\A}, cntimg if ctt
  end

  def append_hatebu_iframe(url, ctt)
    edited_url = nil
    if url.start_with? "https"
      edited_url = url.gsub %r{https://}, "s/"
    else
      edited_url = url.gsub %r{http://}, ""
    end
    iframe = %{<iframe src="http://b.hatena.ne.jp/entry/#{edited_url}"></iframe>}
    ctt.add_text(iframe) if ctt
  end

  def get_content(el)
    if el.elements['content:encoded']
      @content_exists = true
      return el.elements['content:encoded']
    elsif el.elements['content']
      return el.elements['content']
    elsif el.elements['description']
      return el.elements['description']
    else
      ap "!!>> No Content Found. <<!!"
    end
    nil
  end

  def delete_element(el)
    if @debug
      title = el.elements['title'].text
      el.elements['title'].text = "(Filtered) #{title}"
    else
      case @doc.root.name.downcase
      when "rdf"
        @doc.root.elements.delete el
      when "rss"
        @doc.root.elements['channel'].delete el
      when "feed"
        @doc.root.elements.delete el
      end
    end
  end

  def show_all_titles()
    @doc.elements.each('//item') do |el|
      puts el.elements['title'].text
    end
  end

  private

    def is_ng_title(title)
      return false unless @rules
      return false unless @rules["mute"]["title"]
      @rules["mute"]["title"].each do |word|
        next if word.blank?
        return true if title.upcase.include? word.upcase
      end
      false
    end

    def is_ng_domain(url)
      domain = get_domain(url)
      return false unless @rules
      return false unless @rules["mute"]["domain"]
      return true if @rules["mute"]["domain"].include? domain
      false
    end

    def is_ng_urlprefix(url)
      url_text = url.sub %r{^https?://}, ''
      return false unless @rules
      return false unless @rules["mute"]["url_prefix"]
      @rules["mute"]["url_prefix"].each do |prefix|
        next if prefix.blank?
        return true if url_text.start_with? prefix
      end
      false
    end

    def get_domain(url)
      url.match(%r{^(.+?)://(.+?):?(\d+)?(/.*)?$})[2]
    end

    def make_compact(arr)
      unless arr.blank?
        arr = arr.reject(&:blank?)
      end
      arr
    end

end
