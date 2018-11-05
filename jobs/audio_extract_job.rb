class AudioExtractJob
  @queue = :extract

  def self.perform(youtube_id, who=nil, name)
    puts "cool, cool, you want to play #{youtube_id}"
    puts `youtube-dl -x --id --audio-format 'mp3' --download-archive ytdl.arch -- '#{youtube_id}'`
    name ||= `youtube-dl -e #{youtube_id}`
    unless $?.success?
    end

    Resque.enqueue(AudioPlayJob, youtube_id, who, name)
  end
end
