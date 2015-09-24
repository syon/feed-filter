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
    @feed = ff.fetch_feed(params[:feed_id])
    raise unless @feed
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
  redirect to('/') unless @feed
  slim :view
end

get '/edit/:feed_id' do
  ff = FeedFilter.new
  @feed = ff.fetch_feed(params[:feed_id])
  redirect to('/') unless @feed
  slim :edit
end

post '/edit/:feed_id' do
  ff = FeedFilter.new
  feed = ff.update(params)
  redirect to('/') unless feed
  redirect to("/view/#{feed.feed_id}")
end

post '/delete/:feed_id' do
  ff = FeedFilter.new
  feed = ff.delete(params[:feed_id])
  redirect to('/')
end

get '/preview' do
  ff = FeedFilter.new
  @titles = ff.fetch_filtered_titles(params)
  @titles.to_json
end
