#YTQ = YouTube Queue

Turn your Macbook into a YouTube jukebox server

## Requirements

You have to have youtube-dl installed on your machine `brew install youtube-dl`, as well as ffmpeg `brew install ffmpeg`. Note: youtube-dl uses an unpublished youtube api, which changes without warning. Typically this results in the youtube-dl maintainers providing updates, which you can install with `brew upgrade youtube-dl`

Install and have redis running `brew install redis` and follow instructions for running it as a service

Verified with ruby 1.9.3 up through 2.5.1 and other versions are likely ok too

Designed for and tested on Macbook. Modification to use on other systems is likely possible

## How To

### Setup and Run

#### The web service endpoint

Clone this repo `git clone https://github.com/groddeck/ytq`

From the cloned repo (`cd ytq`) first `bundle install` and then run `foreman start`

This will start up your YouTube Queue Server on port 5300

To make sure it's running, browse to localhost:5300 from your machine, and you should see the search form.

#### Queue Consumers

You can invoke `resque-web` to inspect the queue of audio to be played, check for errors and see other stats.

### Connect and Play Music

Your machine has to be visible to other machines on a network to enqueue selections from them. A handy tool is `localtunnel` which can open a reverse proxy to your machine that will be accessible outside your network.

#### Search Page
From a browser, make a request to *your-ip*:5300

Enter a search term to find a youtube video to play and submit the form.

The result should be a list of matches for your search term. Click to add a selection to the queue for playback.

The YouTube video will be downloaded, ripped to MP3, and played on the system audio output of the host machine running the YTQ server.

#### REST Interface
From a browser, or with curl on the command line, make a request to *your-ip*:5300/play/*youtube_id* - where *youtube_id* is the part of a youtube video URL after the `?v=` parameter, e.g.: http://www.youtube.com/watch?v=asdf - "asdf" is the youtube_id.

In a multi-user scenario, if you want to identify the person who has made a selection, add the `?who=name` parameter to the end of the request URL and that information will be visible in the queue viewer.
