require 'redis'
require 'excon'
require 'json'

class SearchJob
  @queue = :search
  APP_HOST = ENV['APP_HOST'] || 'http://barchord.app'

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
    Excon.post("#{APP_HOST}/api/search", query: {q: term, results:  results.to_json})
  end
end
