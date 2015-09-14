require 'uri'
require_relative 'lib/feed_filter'

get '/' do
  @say = "Feed Filter"
  @all_feeds = Feeds.all
  slim :index
end

get '/feed/:feed_id' do
  begin
    ff = FeedFilter.new(params[:feed_id])
    content = ff.get_filtered_content
    content_type :"application/xml; charset=#{ff.charset}"
    content
  rescue => e
    return "Error"
  end
end
