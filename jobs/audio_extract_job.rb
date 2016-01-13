class AudioExtractJob
  @queue = :extract

  def self.perform(youtube_id, who=nil)
    puts "cool, cool, you want to play #{youtube_id}"
    if who
      `say Thanks for the selection, #{who}`
    end

    puts `youtube-dl -x -t --audio-format 'mp3' -- '#{youtube_id}'`
    unless $?.success?
    	`say Error downloading video`
    end

    Resque.enqueue(AudioPlayJob, youtube_id, who)
  end
end
