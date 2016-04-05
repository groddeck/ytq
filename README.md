#YTQ = YouTube Queue

Turn your mac into a YouTube jukebox server

## Requirements

You have to have youtube-dl installed on your machine `brew install youtube-dl`, as well as ffmpeg `brew install ffmpeg`.

Install and have redis running `brew install redis` and follow instructions for running it as a service

Verified with ruby 1.9.3, though other versions are probably ok

Designed for and tested on Macbook. Modification to use on other systems is likely possible

## How To

### Setup and Run

#### The web service endpoint

Clone this repo `git clone https://github.com/groddeck/ytq`

From the cloned repo (`cd ytq`) first `bundle install` and then run `ruby ytq.rb -o 0.0.0.0`

This will start up your YouTube Queue Server on port 4567

To make sure it's running, browse to localhost:4567 from your machine, and you should see it return a test message ("OK. The server is running and ready to take requests.").

#### Queue Consumers

In a separate terminal, create a consumer to process downloading requests with `QUEUE=extract rake resque:work`

In another terminal, create a consumer to process playing requests with `QUEUE=playlist rake resque:work`

You can invoke `resque-web` to inspect the queue of audio to be played, check for errors and see other stats.

### Connect and Play Music

Your machine has to be visible to other machines on a network to enqueue selections from them.

#### Search Page
From a browser, make a request to *your-ip*:4567/search

Enter a search term to find a youtube video to play and submit the form.

The result should be a list of matches for your search term. Click `Enqueue` next to a select to add it to the queue for playback. 

The YouTube video will be downloaded, ripped to MP3, and played on the system audio output of the host machine running the YTQ server.

#### REST Interface
From a browser, or with curl on the command line, make a request to *your-ip*:4567/play/*youtube_id* - where *youtube_id* is the part of a youtube video URL after the `?v=` parameter, e.g.: http://www.youtube.com/watch?v=asdf - "asdf" is the youtube_id.

In a multi-user scenario, if you want to identify the person who has made a selection, add the `?who=name` parameter to the end of the request URL and the system will announce the given name before playing it.
