class AudioJob
  @queue = :playlist

  def self.perform(youtube_id, who=nil)
    puts "cool, cool, you want to play #{youtube_id}"
    if who
      `say Thanks for the selection, #{who}`
    end

    puts `youtube-dl -x -t --audio-format 'mp3' #{youtube_id}`
    unless $?.success?
    	`say Error downloading video`
    end

    `find . -name *#{youtube_id}.mp3 | xargs -I arg open "arg"`
    unless $?.success?
    	`say Error playing song`
    end
  end
end
