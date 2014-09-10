require 'sinatra'

get '/' do
  'Hello, World!'
end

get '/play/:yt_id' do
  puts "cool, cool, you want to play #{params[:yt_id]}"
  puts `youtube-dl -x -t --audio-format 'mp3' #{params[:yt_id]}`
  `find . -name *#{params[:yt_id]}.mp3 | xargs -I arg open "arg"`
end
