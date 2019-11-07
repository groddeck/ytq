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
  # Extract
  begin
    res = Excon.post("#{QUEUE_HOST}/begin.json", query: {context: CONTEXT, topic: 'extract'} )
    p res.body
    if res.body && !res.body.empty?
      js = JSON.parse(res.body)
      msg = js['body']
      id = msg['id']
      fulltitle = msg['fulltitle']
      img = msg['img']
      `touch db.txt`
      File.open('db.txt', 'a') do |f|
        f.puts( {id: id, fulltitle: fulltitle, img: img}.to_json )
      end
      Resque.enqueue(AudioExtractJob, id, nil, fulltitle, img)
    end
  rescue => e
    puts 'an error occurred queueing audio download:'
    puts e
  end

  sleep 2
end
