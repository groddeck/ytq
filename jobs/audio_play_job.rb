require 'excon'

class AudioPlayJob
  @queue = :playlist
  APP_HOST = ENV['APP_HOST'] || 'http://barchord.app'

  def self.perform(youtube_id, who=nil, name, img)
    begin
      Excon.post("#{APP_HOST}/api/nowplaying", query: {fulltitle: name, id: youtube_id, img: img})
    rescue
      puts "error setting now-playing"
    end
    `find . -name #{youtube_id}.mp3 | xargs -I arg mplayer -slave "arg"`
    unless $?.success?
    end
  end
end
