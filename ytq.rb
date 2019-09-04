require 'sinatra'
require 'resque'
require 'json'
require 'excon'
require 'redis'
require_relative 'jobs/audio_extract_job'
require_relative 'jobs/audio_play_job'

class Search
  def self.searches
    @redis ||= Redis.new
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
    until result = searches.get(term) do
      puts "awaiting non-nil redis result for #{term}"
    end
    puts "got result: #{result}"
    result
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
  term = params[:q]
  results = params[:results]
  searches[term] = results
end

def queue
  (0...Resque.size('playlist')).map do |i|
    Resque.peek('playlist', i)['args']
  end + 
  (0...Resque.size('extract')).map do |i|
    Resque.peek('extract', i)['args']
  end
end

get '/api/queue' do
  queue.map{|track| {fulltitle: track[2], id: track[0], img: track[3]}}.to_json
end

get '/tracks/:yt_id/remove' do
  track = queue.select { |track|
    track[0] == params[:yt_id]
  }.first
  result = Resque.dequeue(AudioPlayJob, *track)
  if result == 1
    "Removed track: #{track} from playback queue"
  else
    "Unable to remove track: #{track}"
  end
end
