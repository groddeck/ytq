class AudioPlayJob
  @queue = :playlist

  def self.perform(youtube_id, who=nil, name, img)
    `find . -name #{youtube_id}.mp3 | xargs -I arg mplayer -slave "arg"`
    unless $?.success?
    end
  end
end
