require 'sinatra'
require 'resque'
require 'json'
require_relative 'jobs/audio_extract_job'

get '/' do
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
  (0...Resque.size('playlist')).map do |i|
    "#{Resque.peek('playlist', i)['args']}"
  end.join('<br>')
end
