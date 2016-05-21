require 'sinatra'
require 'resque'
require 'json'
require_relative 'jobs/audio_extract_job'
require_relative 'jobs/audio_play_job'

def header(active)
  head_tag = <<-eos
  <head>
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>

    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">

    <!-- Optional theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous">

    <!-- Latest compiled and minified JavaScript -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>
  </head>
  eos
  head_tag + nav_bar(active)
end

def nav_bar(active)
  active_class = 'class="active"'
  search_class =  active_class if active == :search
  queue_class = active_class if active == :queue
  <<-eos
    <nav class="navbar navbar-inverse navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">YTQ</a>
        </div>
        <div id="navbar" class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li #{search_class}>#{search_link}</li>
            <li #{queue_class}>#{queue_link}</li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </nav>
  eos
end

def search_link; "<a href='/'>search</a>" ; end

def queue_link; "<a href='/queue'>Queue</a>"; end

get '/' do
  search
end

get '/play/:yt_id' do
  Resque.enqueue(AudioExtractJob, params[:yt_id], params[:who])
  header(nil) + 
  "<p>Received and enqueued your selection: #{params[:yt_id]}</p>" + 
  form_markup
end

get '/search' do
  search
end

def form_markup
  "<form action='/search'><input name='q'><input type='submit'></form>"
end

def search
  response_text = form_markup
  if params[:q]
    results_json = `youtube-dl ytsearch10:"#{params[:q]}" -s --dump-json`
    results = results_json.split("\n")
    response_text += "<h1>Search results<h2>"
    results.each do |result|
      result_record = JSON.parse(result)
      response_text += "<div><img width='50' src='#{result_record["thumbnail"]}'>#{result_record["fulltitle"]} <a href='/play/#{result_record["id"]}'>Enqueue</a></div>"
    end
  end
  header(:search) + 
  '<div class="container">' + 
  response_text + 
  '</div>'
end

get '/api/search' do
  results_json = `youtube-dl ytsearch10:"#{params[:q]}" -s --dump-json`
  results = results_json.split("\n")
  "[#{results.join(',')}]"
end

get '/queue' do
  q = queue
  header(:queue) + 
  '<div class="container">' + 
  (q.empty? ? 'Nothing is queued up right now' :
  queue.map{|track| "#{track[2]} | <a href='/tracks/#{track[0]}/remove'>remove</a>"}.join('<br>')) + 
  '</div>'
end

def queue
  # (0...Resque.size('extract')).map do |i|
  #   Resque.peek('extract', i)['args']
  # end +
  (0...Resque.size('playlist')).map do |i|
    Resque.peek('playlist', i)['args']
  end
end

get '/tracks/:yt_id/remove' do
  track = queue.select { |track|
    track[0] == params[:yt_id]
  }.first
  result = Resque.dequeue(AudioPlayJob, *track)
  '<div class="container">' + 
  header(nil) + if result == 1
    "Removed track: #{track} from playback queue"
  else
    "Unable to remove track: #{track}"
  end + 
  '</div>'  
end

get '/bootstrap' do
  <<-eos

  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
      <meta name="description" content="">
      <meta name="author" content="">
      <link rel="icon" href="../../favicon.ico">

      <title>Starter Template for Bootstrap</title>

      <!-- Bootstrap core CSS -->
      <link href="../../dist/css/bootstrap.min.css" rel="stylesheet">

      <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
      <link href="../../assets/css/ie10-viewport-bug-workaround.css" rel="stylesheet">

      <!-- Custom styles for this template -->
      <link href="starter-template.css" rel="stylesheet">

      <!-- Just for debugging purposes. Don't actually copy these 2 lines! -->
      <!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->
      <script src="../../assets/js/ie-emulation-modes-warning.js"></script>

      <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
      <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
      <![endif]-->
    </head>

    <body>

      <nav class="navbar navbar-inverse navbar-fixed-top">
        <div class="container">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="#">Project name</a>
          </div>
          <div id="navbar" class="collapse navbar-collapse">
            <ul class="nav navbar-nav">
              <li class="active"><a href="#">Home</a></li>
              <li><a href="#about">About</a></li>
              <li><a href="#contact">Contact</a></li>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </nav>

      <div class="container">

        <div class="starter-template">
          <h1>Bootstrap starter template</h1>
          <p class="lead">Use this document as a way to quickly start any new project.<br> All you get is this text and a mostly barebones HTML document.</p>
        </div>

      </div><!-- /.container -->


      <!-- Bootstrap core JavaScript
      ================================================== -->
      <!-- Placed at the end of the document so the pages load faster -->

      <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>

      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>

      <script>window.jQuery || document.write('<script src="../../assets/js/vendor/jquery.min.js"><\/script>')</script>

      <script src="../../dist/js/bootstrap.min.js"></script>
    </body>
  </html>
  eos
end