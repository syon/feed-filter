require 'sinatra'
require 'sinatra/content_for'
require 'active_support/core_ext'
require_relative 'lib/feed_filter'
require 'ap'

get '/' do
  slim :index
end

get '/feed/:feed_id' do
  begin
    ff = FeedFilter.new()
    ff.prepare_one(params[:feed_id])
    content = ff.content
    content_type :"application/xml; charset=#{ff.charset}"
    content
  rescue => e
    ap e
    return "Error"
  end
end

get '/recent' do
  cookies[:recent_ids] = [] if cookies[:recent_ids].blank?
  recent_ids = cookies[:recent_ids].split '&'
  ff = FeedFilter.new()
  @all_feeds = ff.get_recent_feeds(recent_ids)
  return @all_feeds.to_json
end

get '/new' do
  slim :new
end

post '/new' do
  redirect to('/') unless guard(params)
  ff = FeedFilter.new
  @feed = ff.create(params)
  add_recent(@feed.feed_id)
  redirect to("/view/#{@feed.feed_id}")
end

get '/view/:feed_id' do
  ff = FeedFilter.new
  @feed = ff.fetch_feed(params[:feed_id])
  redirect to('/') unless @feed
  @titles = ff.view_filtered_titles()
  slim :view
end

get '/edit/:feed_id' do
  ff = FeedFilter.new
  @feed = ff.fetch_feed(params[:feed_id])
  redirect to('/') unless @feed
  slim :edit
end

post '/edit/:feed_id' do
  redirect to('/') unless guard(params)
  ff = FeedFilter.new
  feed = ff.update(params)
  add_recent(feed.feed_id)
  redirect to('/') unless feed
  redirect to("/view/#{feed.feed_id}")
end

post '/delete/:feed_id' do
  ff = FeedFilter.new
  feed = ff.delete(params)
  del_recent(params[:feed_id])
  redirect to('/')
end

post '/preview' do
  return unless guard(params)
  ff = FeedFilter.new
  items = ff.preview_filtered_titles(params)
  items.to_json
end

def add_recent(feed_id)
  recent_ids = cookies[:recent_ids].split '&'
  recent_ids << feed_id
  recent_ids.uniq!
  response.set_cookie("recent_ids", {
    :value => recent_ids,
    # domain is required on Safari.
    :domain => "syon-feed-filter.herokuapp.com",
    :path => "/",
    :expires => Time.now + (3600 * 24 * 14)
  })
end

def del_recent(feed_id)
  recent_ids = cookies[:recent_ids].split '&'
  idx = recent_ids.find_index(feed_id)
  recent_ids.delete_at(idx)
  cookies[:recent_ids] = recent_ids
end

def guard(params)
  return false unless valid_url(params[:feed_url])
  return true
end

def valid_url(feed_url)
  begin
    url = URI.parse(feed_url)
    req = Net::HTTP.new(url.host, url.port)
    res = req.request_head(url.path)
    return true
  rescue => e
    p e
    return false
  end
end
