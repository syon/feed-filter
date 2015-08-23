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

get '/' do
  @say = "Hello World."
  slim :index
end

get '/feed' do
  begin
    feed_url = params[:url]
    raise unless URI.regexp(%w(http https)) =~ feed_url

    ff = FeedFilter.new(feed_url, $user_rules, {debug: true})
    content = ff.get_filtered_content
    content_type :"application/xml; charset=#{ff.charset}"
    content
  rescue => e
    return "Error"
  end
end

get '/oauth2callback' do
  p params
  params
end
