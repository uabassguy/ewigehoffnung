
module EH
  
  def self.animations
    return @animations
  end
  
  def self.animations=(hsh)
    @animations = hsh
  end
  
  def self.anim(anim)
    return animations[anim].clone
  end
  
  class Animation
    attr_accessor :x, :y
    def initialize(graphic, sx, sy, repeat, frames)
      @anim_frames = EH.tiles("animations/#{graphic}", sx, sy, false)
      @repeat = repeat
      @frames = frames
      @index = 0
      @time = 0
      @x, @y = 0
      @remove = false
    end
    
    def frame
      return @frames[@index]
    end
    
    def play(x, y, z)
      @x, @y, @z = x, y, z
    end
    
    def draw
      return if remove?
      @anim_frames[@index].draw(@x + frame.x, @y + frame.y, @z, 1, 1, frame.color, frame.mode)
      @time += 1
      if @time >= frame.length
        @time = 0
        next_frame
      end
    end
    
    def remove?
      return @remove
    end
    
    private
    
    def next_frame
      @index += 1
      if @index >= @frames.size
        if @repeat
          @index = 0
        else
          @remove = true
        end
      end
    end
  end
  
  class Frame
    attr_reader :length, :color, :x, :y, :mode
    def initialize
      @length = 1
      @color = Gosu::Color::WHITE
      @x, @y = 0, 0
      @mode = :default
    end
  end
  
end
