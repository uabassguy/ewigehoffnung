
module EH
  
  def self.animations
    return @animations
  end
  
  def self.animations=(hsh)
    @animations = hsh
  end
  
  class Animation
    def finitialize(graphic, sx, sy, repeat, frames)
      @graphic = EH.sprite("animations/#{graphic}")
      @sx, @sy = sx, sy
      @repeat = repeat
      @frames = frames
      @index = 0
    end
    
    def frame
      return @frames[@index]
    end
  end
  
  class Frame
    def initialize(length, color, x, y, mode)
      @length = length
      @color = color
      @x, @y = x, y
      @mode = mode
    end
  end
  
end
