require 'redis'
require 'excon'
require 'json'

class SearchJob
  @queue = :search

  def self.perform(term)
    puts "got search term request: #{term}"
    results_json = `youtube-dl ytsearch10:"#{term}" -s --dump-json`
    results = results_json.split("\n")
    results = "[#{results.join(',')}]"
    results_h = JSON.parse(results)
    results = results_h.map do |n|
      n.slice('id', 'fulltitle', 'thumbnail')
    end
    pp results
    # redis = Redis.new
    # redis.set(term, results)
    Excon.post('http://3.228.94.216/api/search', query: {q: term, results:  results.to_json})

    # puts "cool, cool, you want to play #{youtube_id}"
    # puts `youtube-dl -x --id --audio-format 'mp3' --download-archive ytdl.arch -- '#{youtube_id}'`
    # name ||= `youtube-dl -e #{youtube_id}`
    # unless $?.success?
    # end
    #
    # Resque.enqueue(AudioPlayJob, youtube_id, who, name, img)
  end
end
