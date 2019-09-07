require 'sinatra'
require 'resque'
require 'json'
require 'excon'
require 'redis'
require_relative 'jobs/audio_extract_job'
require_relative 'jobs/audio_play_job'

class Search
  def self.searches
    @searches ||= {}
  end

  def self.search(term)
    puts "posting search message to remote q"
    Excon.post('https://curlyq.herokuapp.com/messages', query: {message: {topic: 'search', body: {term: term} }.to_json} )
    # results_json = if searches[term]
    #   searches[term]
    # else
    #   # `youtube-dl ytsearch10:"#{term}" -s --dump-json`
    # end
    # searches[term] = results_json
    until result = searches[term] do
      puts "awaiting non-nil redis result for #{term}"
      puts searches.keys
      sleep 1
    end
    puts "got result: #{result}"
    result
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

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

get '/api/play/:yt_id' do
  # Resque.enqueue(AudioExtractJob, params[:yt_id], params[:who], params[:name], params[:img])
  Excon.post('https://curlyq.herokuapp.com/messages', query: {message: {topic: 'extract', body: {id: params[:yt_id], fulltitle: params[:name], img: params[:img]} }.to_json} )
end

get '/api/search' do
  puts "passing search param to search module: #{params[:q]}"
  results_json = Search.search(params[:q])
  # results = results_json.split("\n")
  # "[#{results.join(',')}]"
end

post '/api/search' do
  puts "got post of search results"
  term = params[:q]
  results = params[:results]
  puts "got term: #{term}"
  pp results
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

def queue
  # (0...Resque.size('playlist')).map do |i|
  #   Resque.peek('playlist', i)['args']
  # end +
  # (0...Resque.size('extract')).map do |i|
  #   Resque.peek('extract', i)['args']
  # end
  res = Excon.get('https://curlyq.herokuapp.com/messages.json')
  if res && res.body
    msg = JSON.parse(res.body)
    msg.select{ |track| track['topic'] == 'extract' }.map{ |track| track['body'] }.map{ |track| track.slice('fulltitle', 'id', 'img') }
  else
    []
  end
end

get '/api/queue' do
  # queue #.map{|track| {fulltitle: track[2], id: track[0], img: track[3]}}.to_json
  (Playlist.nowplaying + Playlist.playlist).to_json
end

get '/tracks/:yt_id/remove' do
  # track = queue.select { |track|
  #   track[0] == params[:yt_id]
  # }.first
  # result = Resque.dequeue(AudioPlayJob, *track)
  # if result == 1
  #   "Removed track: #{track} from playback queue"
  # else
  #   "Unable to remove track: #{track}"
  # end
  Excon.post('https://curlyq.herokuapp.com/messages', query: {message: {topic: 'remove', body: {id: params[:yt_id]} }.to_json} )
  'ok'
end
