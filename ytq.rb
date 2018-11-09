require 'sinatra'
require 'resque'
require 'json'
require_relative 'jobs/audio_extract_job'
require_relative 'jobs/audio_play_job'

class Search
  def self.searches
    @searches ||= {}
  end

  def self.search(term)
    results_json = if searches[term]
      searches[term]
    else
      `youtube-dl ytsearch10:"#{term}" -s --dump-json`
    end
    searches[term] = results_json
  end
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

get '/api/play/:yt_id' do
  Resque.enqueue(AudioExtractJob, params[:yt_id], params[:who], params[:name], params[:img])
end

get '/api/search' do
  results_json = Search.search(params[:q])
  results = results_json.split("\n")
  "[#{results.join(',')}]"
end

def queue
  (0...Resque.size('extract')).map do |i|
    Resque.peek('extract', i)['args']
  end +
  (0...Resque.size('playlist')).map do |i|
    Resque.peek('playlist', i)['args']
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
