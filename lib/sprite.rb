
# Gosu::Image wrapper

module EH
  # cache system borks inheritance, so we need to wrap a Gosu::Image instance
  class Sprite
    attr_reader :file
    attr_accessor :color
    @@cache = {}
    def initialize(window, file, tile=false)
      warn("WARNING: class Sprite is deprecated (#{file})")
      return EH.sprite(file, tile)
    end
    def draw(a=nil, b=nil, c=nil, d=nil, e=nil)
    end
    def img
      return EH.sprite("missing", false)
    end
    def width
      return 1
    end
    def height
      return 1
    end
  end
  
  @@cache = {}
  def self.sprite(file, tile=false)
    if @@cache[file]
      return @@cache[file]
    end
    begin
      img = Gosu::Image.new(window, "graphics/#{file}.png", tile)
      @@cache.store(file, img)
      return img
    rescue RuntimeError
      warn("ERROR: Failed to open graphic #{file}")
      file = "missing"
      retry
    end
  end
  
end
