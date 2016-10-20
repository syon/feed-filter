class FilterFactory

  def initialize(doc, feed_url, filter_rules)
    @doc = doc
    @feed_url = feed_url
    @rules = filter_rules
  end

  def filtering(is_preview)
    @debug = is_preview
    edit_hotentry_once
    entries = self.class.get_entries(@doc)
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
        d = get_edited_hotentry(ctt, el)
        edited = (%(
          #{d[:heroimg]}
          <p>#{d[:favicon]} #{d[:hbcount]}</p>
          <p>#{d[:desc]}</p>
        ))
        edited << get_hatebu_iframe(url)
        write_content(el, edited)
      else
        edited = get_content(el).text
        edited.gsub!(%r{\A}, get_hatebu_count(url))
        edited << get_hatebu_iframe(url)
        write_content(el, edited)
      end

    end
  end

  def self.get_entries(doc)
    case doc.root.name.downcase
    when "rdf"
      # RSS 1.0
      return doc.get_elements('//item')
    when "rss"
      # RSS 2.0
      return doc.get_elements('//item')
    when "feed"
      # Atom
      return doc.get_elements('//entry')
    end
  end

  private

    def edit_hotentry_once()
      if @feed_url.include?("hotentry")
        delete_element_by_query('//channel/atom10:link')
        delete_element_by_query('//channel/feedburner:info')
      end
    end

    def delete_element_by_query(q)
      dels = @doc.get_elements(q)
      dels.each do |d|
        d.remove
      end
    end

    def clean_url(el)
      url = el.elements['link'].text
      url = el.elements['link'].attribute('href').to_s unless url
      url.gsub! %r{\?ncid=rss_truncated}, ""
      el.elements['link'].text = url
      url
    end

    def get_title(el, url)
      title = el.elements['title'].text
      if url.match(%r{https?://anond.hatelabo.jp})
        title << " :: anond"
      end
      el.elements['title'].text = title
      title
    end

    def get_content(el)
      if el.elements['content:encoded']
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

    def get_edited_hotentry(ctt, el)
      d = parse_hotentery(ctt.text, el)
      d
    end

    def get_hatebu_count(url)
      %{<cite><img src="http://b.hatena.ne.jp/entry/image/#{url}" /></cite>}
    end

    def get_hatebu_iframe(url)
      edited_url = nil
      if url.start_with? "https"
        edited_url = url.gsub %r{https://}, "s/"
      else
        edited_url = url.gsub %r{http://}, ""
      end
      %{<iframe src="http://b.hatena.ne.jp/entry/#{edited_url}"></iframe>}
    end

    def get_content(el)
      if el.elements['content:encoded']
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

    def write_content(el, edited)
      tgt = nil
      if el.elements['content:encoded']
        tgt = el.elements['content:encoded']
      elsif el.elements['content']
        tgt = el.elements['content']
      elsif el.elements['description']
        tgt = el.elements['description']
      else
        ap "!!>> Content Not Found. <<!!"
      end
      tgt.text = nil
      REXML::CData.new(%(#{edited}), nil, tgt)
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

end
