require 'excon'

class AudioExtractJob
  @queue = :extract
  APP_HOST = ENV['APP_HOST'] || 'http://barchord.app'
  CONTEXT = ENV['CONTEXT'] || 'default'

  def self.perform(youtube_id, who=nil, name, img)
    puts "request to play #{youtube_id}"
    Excon.post("#{APP_HOST}/api/playlist", query: {context: CONTEXT, fulltitle: name, id: youtube_id, img: img})
    puts `youtube-dl -x --id --audio-format 'mp3' --download-archive ytdl.arch -- '#{youtube_id}'`
    name ||= `youtube-dl -e #{youtube_id}`
    unless $?.success?
    end

    Resque.enqueue(AudioPlayJob, youtube_id, Time.now.to_i, name, img)
  end
end
