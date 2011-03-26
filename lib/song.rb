
module EH
  # cache system borks inheritance, so we need to wrap a Gosu::Song instance
  class Song
    attr_reader :file
    @@cache = {}
    def initialize(file)
      @file = file
      if @@cache[file]
        @song = @@cache[file]
        return
      end
      begin
        @song = Gosu::Song.new(EH.window, "music/#{file}.mp3")
        @@cache.store(file, @song)
      rescue RuntimeError
        puts("ERROR: Failed to open music #{file}")
        return
      end
    end
    def song
      return @song
    end
    def stop
      @song.stop
    end
    def pause
      @song.pause
    end
    def volume
      return @song.volume
    end
    def volume=(vol)
      @song.volume = vol
    end
    def play(loop=true)
      @song.volume = EH.config[:volume]+1.0 # FIXME no effect?
      @song.play(loop)
    end
  end
end
