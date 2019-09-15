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

  # Remove
  begin
    res = Excon.post("#{QUEUE_HOST}/begin.json", query: {topic: 'remove'} )
    pp res.body
    if res.body && !res.body.empty?
      js = JSON.parse(res.body)
      msg = js['body']
      ytid = msg['id']

      queue = Queue.queue
      track = queue.select { |track|
        track[0] == ytid
      }.first
      result = Resque.dequeue(AudioPlayJob, *track)
      if result == 1
        "Removed track: #{track} from playback queue"
      else
        "Unable to remove track: #{track}"
      end
    end
  rescue
    puts 'an error occurred removing'
  end

  sleep 2
end
