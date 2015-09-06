require 'uri'
require_relative 'lib/feed_filter'

$user_rules = {
  mute: {
    title: [
      "PR:",
      "スポ",
      "新聞",
      "ニュース",
      "Windows"
    ],
    domain: [
      "netgeek.biz",
      "hamusoku.com",
      "togetter.com"
    ]
  }
}

$user_feeds = {
  '1441518694' => {feed_url: 'http://b.hatena.ne.jp/hotentry.rss'},
  '1441518830' => {feed_url: 'http://japanese.engadget.com/rss.xml'},
  '1441521964' => {feed_url: 'http://qiita.com/tags/Docker/feed.atom'}
}

get '/' do
  @say = "Hello World."
  slim :index
end

get '/feed/:feed_id' do
  feed = $user_feeds[params[:feed_id]]
  begin
    feed_url = feed[:feed_url]
    raise unless URI.regexp(%w(http https)) =~ feed_url

    ff = FeedFilter.new(feed_url, $user_rules, {debug: true})
    content = ff.get_filtered_content
    content_type :"application/xml; charset=#{ff.charset}"
    content
  rescue => e
    return "Error" + e.to_s
  end
end

get '/oauth2callback' do
  p params
  params
end
