require 'uri'
require_relative 'lib/feed_filter'

get '/' do
  @say = "Feed Filter"
  @all_feeds = Feeds.all
  slim :index
end

get '/feed/:feed_id' do
  begin
    ff = FeedFilter.new
    ff.fetch_feed(params[:feed_id])
    content = ff.get_filtered_content
    content_type :"application/xml; charset=#{ff.charset}"
    content
  rescue => e
    return "Error"
  end
end

get '/new' do
  slim :new
end

post '/new' do
  ff = FeedFilter.new
  @feed = ff.create(params)
  redirect to("/view/#{@feed.feed_id}")
end

get '/view/:feed_id' do
  ff = FeedFilter.new
  @feed = ff.fetch_feed(params[:feed_id])
  slim :view
end
