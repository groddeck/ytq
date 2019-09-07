require 'excon'

class AudioExtractJob
  @queue = :extract

  def self.perform(youtube_id, who=nil, name, img)
    puts "request to play #{youtube_id}"
    Excon.post('http://barchord.app/api/playlist', query: {fulltitle: name, id: youtube_id, img: img})
    puts `youtube-dl -x --id --audio-format 'mp3' --download-archive ytdl.arch -- '#{youtube_id}'`
    name ||= `youtube-dl -e #{youtube_id}`
    unless $?.success?
    end

    Resque.enqueue(AudioPlayJob, youtube_id, who, name, img)
  end
end
