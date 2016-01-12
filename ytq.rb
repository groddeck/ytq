require 'sinatra'
require 'resque'
require_relative 'jobs/audio_extract_job'

get '/' do
  'Hello, World!'
end

get '/play/:yt_id' do
  Resque.enqueue(AudioExtractJob, params[:yt_id], params[:who])
  "Received and enqueued your selection: #{params[:yt_id]}"
end
