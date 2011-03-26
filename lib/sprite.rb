
# Gosu::Image wrapper

module EH
  # cache system borks inheritance, so we need to wrap a Gosu::Image instance
  class Sprite
    attr_reader :file
    @@cache = {}
    def initialize(window, file, tile=false)
      @file = file
      if @@cache[file]
        @img = @@cache[file]
        return
      end
      begin
        @img = Gosu::Image.new(window, "graphics/#{file.to_s}.png", tile)
        @@cache.store(file, @img)
      rescue RuntimeError
        puts("ERROR: Failed to open graphic #{file}")
        file = "missing"
        retry # this is failsafe because the file is checked on startup
      end
    end
    def img
      return @img
    end
    def draw(x, y, z)
      @img.draw(x, y, z)
    end
    def width
      return @img.width
    end
    def height
      return @img.height
    end
  end
end
