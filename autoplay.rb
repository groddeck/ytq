require 'resque'
require 'json'
require 'excon'
require_relative 'jobs/audio_extract_job'
require_relative 'jobs/audio_play_job'
require_relative 'jobs/search_job'

class Queue
  def self.queue
    queue = (0...Resque.size('playlist')).map do |i|
      Resque.peek('playlist', i)['args']
    end
  end
end

QUEUE_HOST = ENV['QUEUE_HOST'] || 'https://curlyq.herokuapp.com'

while true do

  # Autoplay
  begin
    puts "checking queue for tracks"
    queue = Queue.queue
    puts "found: #{queue}"
    puts "checking queue size"
    if queue.empty?
      puts "queue empty"
      tracks = Dir["./*.mp3"]
      puts "tracks: #{tracks}"
      track = tracks.sample
      puts "track: #{track}"
      track_id = track.split('.')[1].split('/')[1]
      puts "track_id: #{track_id}"
      track = nil
      `touch db.txt`
      File.open("db.txt", "r").each_line do |line|
        record = JSON.parse(line)
        if record['id'] == track_id
          track = record
          break
        end
      end
      next unless track
      Resque.enqueue(AudioPlayJob, track['id'], nil, track['fulltitle'], track['img'])
    end
  rescue => error
    puts 'an error occurred attempting random autoplay:'
    puts error
  end

  sleep 2
end
