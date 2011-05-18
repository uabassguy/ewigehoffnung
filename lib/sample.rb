
module EH
  # cache system borks inheritance, so we need to wrap a Gosu::Sample instance
  class Sample
    attr_reader :file
    @@cache = {}
    def initialize(file)
      @file = file
      if @@cache[file]
        @sample = @@cache[file]
        return
      end
      begin
        @sample = Gosu::Sample.new("sounds/#{file}.wav")
        @@cache.store(file, @sample)
      rescue RuntimeError
        puts("ERROR: Failed to open sound #{file}")
        return
      end
    end
    def sample
      return @sample
    end
    def play(vol=1.0, speed=1, looping=false)
      vol *= EH.config[:volume]
      @sample.play(vol, speed, looping)
    end
  end
end
