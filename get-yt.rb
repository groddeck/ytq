require 'sinatra'

get '/' do
  'Hello, World!'
end

get '/play/:yt_id' do
  puts "cool, cool, you want to play #{params[:yt_id]}"
  if params[:who]
    `say Thanks for the selection, #{params[:who]}`
  end
  puts `youtube-dl -x -t --audio-format 'mp3' #{params[:yt_id]}`
  # `say thanks for suggestion!`
  `find . -name *#{params[:yt_id]}.mp3 | xargs -I arg open "arg"`
  # `say alright everyone time to choose another song`
end
