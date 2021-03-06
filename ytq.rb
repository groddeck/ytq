require 'sinatra'
require 'resque'
require 'json'
require 'excon'
require 'redis'
require_relative 'jobs/audio_extract_job'
require_relative 'jobs/audio_play_job'
require 'sinatra/cookies'
require 'google/apis/youtube_v3'

QUEUE_HOST = ENV['QUEUE_HOST'] || 'https://curlyq.herokuapp.com'

class Search
  def self.searches
    @searches ||= {}
  end

  def self.search(term, context)
    puts "posting search message to remote q"
    qh = ENV['QUEUE_HOST'] || 'https://curlyq.herokuapp.com'
    key = ENV['YT_KEY']
    url = "#{qh}/messages"
    puts url
    # Excon.post("#{url}", query: {message: {context: context, topic: 'search', body: {term: term} }.to_json} )
    #
    # until result = searches[term] do
    #   puts "awaiting non-nil redis result for #{term}"
    #   puts searches.keys
    #   sleep 1
    # end
    client = Google::Apis::YoutubeV3::YouTubeService.new
    client.key = key
    api_res = client.list_searches('snippet', q: term, max_results: 10, type: 'video')
    result = api_res.items.map do |item|
      {id: item.id.video_id, fulltitle: item.snippet.title, thumbnail: item.snippet.thumbnails.default.url}
    end
    puts "got result: #{result}"
    result.to_json
  end
end

class Playlist
  def self.playlist
    @playlist ||= []
  end

  def self.nowplaying
    @nowplaying ||= []
  end

  def self.nowplaying=(np)
    @playlist.shift
    @nowplaying = np
  end
end

get '/api/skip' do
  `pkill -f mplayer`
end

get '/admin' do
  send_file File.expand_path('admin.html', settings.public_folder)
end

get '/' do
  context = params[:context] || cookies[:context]
  if context == nil
    send_file File.expand_path('context.html', settings.public_folder)
  end

  cookies[:context] = context
  
  puts ">>> sinatra detected cookies:"
  puts request.cookies
  
  send_file File.expand_path('index.html', settings.public_folder)
end

get '/api/play/:yt_id' do
  Excon.post("#{QUEUE_HOST}/messages", query: {message: {context: cookies[:context], topic: 'extract', body: {id: params[:yt_id], fulltitle: params[:name], img: params[:img]} }.to_json} )
end

get '/api/search' do
  puts "passing search param to search module: #{params[:q]}"
  results_json = Search.search(params[:q], cookies[:context])
end

post '/api/search' do
  puts "got post of search results"
  term = params[:q]
  results = params[:results]
  puts "got term: #{term}"
  p results
  Search.searches[term] = results
end

post '/api/nowplaying' do
  puts "got nowplaying call with: #{params}"
  payload = [{fulltitle: params[:fulltitle], id: params[:id], img: params[:img]}]
  puts "payload is: #{payload}"
  Playlist.nowplaying = payload
  'ok'
end

post '/api/playlist' do
  payload = {fulltitle: params[:fulltitle], id: params[:id], img: params[:img]}
  Playlist.playlist << payload
  'ok'
end

# def queue
#   res = Excon.get("#{QUEUE_HOST}/messages.json")
#   if res && res.body
#     msg = JSON.parse(res.body)
#     msg.select{ |track| track['topic'] == 'extract' }.map{ |track| track['body'] }.map{ |track| track.slice('fulltitle', 'id', 'img') }
#   else
#     []
#   end
# end

get '/api/queue' do
  (Playlist.nowplaying + Playlist.playlist).to_json
end

get '/tracks/:yt_id/remove' do
  Excon.post("#{QUEUE_HOST}/messages", query: {message: {context: cookies[:context], topic: 'remove', body: {id: params[:yt_id]} }.to_json} )
  'ok'
end
