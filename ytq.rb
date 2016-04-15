require 'sinatra'
require 'resque'
require 'json'
require_relative 'jobs/audio_extract_job'
require_relative 'jobs/audio_play_job'

def header; [search_link, queue_link].join(' | ') + "<br>"; end

def search_link; "<a href='/search'>search</a>" ; end

def queue_link; "<a href='/queue'>queue</a>"; end

get '/' do
  header + 
  'OK. The server is running and ready to take requests.'
end

get '/play/:yt_id' do
  Resque.enqueue(AudioExtractJob, params[:yt_id], params[:who])
  "Received and enqueued your selection: #{params[:yt_id]}<br>" +
  "<form action='/search'><input name='q'><input type='submit'></form><br>"
end

get '/search' do
  response_text = "<form action='/search'><input name='q'><input type='submit'></form><br>"
  if params[:q]
    results_json = `youtube-dl ytsearch10:"#{params[:q]}" -s --dump-json`
    results = results_json.split("\n")
    response_text += "Search results<br>"
    results.each do |result|
      result_record = JSON.parse(result)
      response_text += "<img width='50' src='#{result_record["thumbnail"]}'>#{result_record["fulltitle"]} <a href='/play/#{result_record["id"]}'>Enqueue</a><br>"
    end
  end
  response_text
end

get '/api/search' do
  results_json = `youtube-dl ytsearch10:"#{params[:q]}" -s --dump-json`
  results = results_json.split("\n")
  "[#{results.join(',')}]"
end

get '/queue' do
  queue.map{|track| "#{track[2]} | <a href='/tracks/#{track[0]}/remove'>remove</a>"}.join('<br>')
end

def queue
  (0...Resque.size('playlist')).map do |i|
    Resque.peek('playlist', i)['args']
  end
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
