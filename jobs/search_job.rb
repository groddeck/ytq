require 'redis'
require 'excon'

class SearchJob
  @queue = :search

  def self.perform(term)
    puts "got search term request: #{term}"
    results_json = `youtube-dl ytsearch10:"#{term}" -s --dump-json`
    results = results_json.split("\n")
    results = "[#{results.join(',')}]"
    # redis = Redis.new
    # redis.set(term, results)
    Excon.post('http://3.228.94.216/api/search', query: {q: term, results:  results})

    # puts "cool, cool, you want to play #{youtube_id}"
    # puts `youtube-dl -x --id --audio-format 'mp3' --download-archive ytdl.arch -- '#{youtube_id}'`
    # name ||= `youtube-dl -e #{youtube_id}`
    # unless $?.success?
    # end
    #
    # Resque.enqueue(AudioPlayJob, youtube_id, who, name, img)
  end
end
