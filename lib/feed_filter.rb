require 'rexml/document'
require 'open-uri'

class FeedFilter

  attr_accessor :charset

  def initialize(feed_id)
    @feed = Feeds.where(:feed_id => feed_id.to_i).first
    p @feed
    @feed_url = @feed.feed_url
    @doc = REXML::Document.new(open(@feed_url).read)
    @charset = @doc.xml_decl.encoding
    @rules = @feed.filter_rules
    @debug = true
  end

  def get_filtered_content()
    @doc.elements.each('//item') do |el|
      title = el.elements['title'].text
      url = clean_url(el)
      ctt = get_content(el)

      if is_ng_title(title)
        delete_element(el)
      end

      if is_ng_domain(url)
        delete_element(el)
      end

      clean_invalid_content(ctt)

      if @feed_url.start_with? "http://b.hatena.ne.jp"
        edit_hotentry(el, ctt)
      else
        append_hatebu_count(url, ctt)
      end

      append_hatebu_iframe(url, ctt)
    end

    show_all_titles() if @debug

    formatter = REXML::Formatters::Default.new
    result = formatter.write(@doc.root, '')
    @doc.xml_decl.to_s + "\n" + result
  end

  def clean_url(el)
    url = el.elements['link'].text
    url.gsub! %r{\?ncid=rss_truncated}, ""
    el.elements['link'].text = url
    url
  end

  def edit_hotentry(el, ctt)
    ctt.gsub! %r{</?blockquote[^>]*>}i, ""
    ctt.gsub! %r{ (alt|title)=".*?"}i, ""
    ctt.gsub! %r{<p><a href="http://b.hatena.ne.jp/entry/http.*?</p>}i, ""
    cntimg = "<img src=\"http://b.hatena.ne.jp/entry/image/\\1\" /></cite>"
    ctt.gsub! %r{<a href="(.*?)".*?</a></cite>}i, cntimg

    hbc = el.elements['hatena:bookmarkcount'].text
    if el.elements['description'].text
      el.elements['description'].text = "[#{hbc}] " + el.elements['description'].text
    end
  end

  def clean_invalid_content(ctt)
    ctt.gsub! %r{<[^<]*?\.\.\.$}, ""
  end

  def append_hatebu_count(url, ctt)
    cntimg = %{<cite><img src="http://b.hatena.ne.jp/entry/image/#{url}" /></cite>}
    ctt.gsub! %r{\A}, cntimg
  end

  def append_hatebu_iframe(url, ctt)
    edited_url = nil
    if url.start_with? "https"
      edited_url = url.gsub %r{https://}, "s/"
    else
      edited_url = url.gsub %r{http://}, ""
    end
    iframe = %{<iframe src="http://b.hatena.ne.jp/entry/#{edited_url}"></iframe>}
    ctt << iframe
  end

  def get_content(el)
    if el.elements['content:encoded']
      return el.elements['content:encoded'].text
    elsif el.elements['description']
      return el.elements['description'].text
    end
  end

  def delete_element(el)
    if @debug
      title = el.elements['title'].text
      el.elements['title'].text = "(Filtered) #{title}"
    else
      @doc.root.elements.delete el
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
      @rules["mute"]["title"].each do |word|
        return true if title.include? word
      end
      false
    end

    def is_ng_domain(url)
      domain = get_domain(url)
      return false unless @rules
      return true if @rules["mute"]["domain"].include? domain
      false
    end

    def get_domain(url)
      url.match(%r{^(.+?)://(.+?):?(\d+)?(/.*)?$})[2]
    end

end
