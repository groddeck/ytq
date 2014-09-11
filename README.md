#YTQ = YouTube Queue

Turn your machine into a YouTube jukebox server

## Requirements

You have to have youtube-dl installed on your machine `brew install youtube-dl`

Also have ruby 1.9.3

## How To

### Setup and Run

Clone this repo `git clone https://github.com/groddeck/ytq`

From the cloned repo (`cd ytq`) first `bundle install` and then run `ruby ytq.rb`

This will start up your YouTube Queue Server on port `4567`

To make sure it's running, browse to localhost:4567 from your machine, and you should see it return a test message ("Hello, World!").

### Connect and Play Music

Your machine has to be visible to other machines on a network to enqueue selections.

From a browser, or with curl on the command line, make a request to *your-ip*:4567/play/*youtube_id* - where *youtube_id* is the part of a youtube video URL after the `?v=` parameter, e.g.: http://www.youtube.com/watch?v=asdf - "asdf" is the youtube_id.

The YouTube video will be downloaded, ripped to MP3, and played on the system audio output of the host machine running the YTQ server.
