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
CONTEXT = ENV['CONTEXT'] || 'default'

while true do

  # Search
  begin
    puts "loop to fetch search message from remote q"
    res = Excon.post("#{QUEUE_HOST}/begin.json", query: {context: CONTEXT, topic: 'search'} )
    p res.body
    if res.body && !res.body.empty?
      puts 'got search message'
      js = JSON.parse(res.body)
      msg = js['body']
      puts "search msg body: #{msg}"
      term = msg['term']
      puts "search term: #{term}"
      puts ">>> about to enqueue search..."
      Resque.enqueue(SearchJob, msg['term'])
      puts "<<< enqueued search."
    end
  rescue => error
    puts 'an error occurred searching:'
    puts error
  end

  sleep 2
end
