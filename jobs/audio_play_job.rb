class AudioPlayJob
  @queue = :playlist

  def self.perform(youtube_id, who=nil)
    `find . -name #{youtube_id}.mp3 | xargs -I arg afplay "arg"`
    unless $?.success?
    	`say Error playing song`
    end
  end
end
