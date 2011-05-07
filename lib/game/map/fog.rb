
module EH::Game
  
  class Fog
    
    def initialize(file, sx, sy, a=255, r=255, g=255, b=255)
      @img = EH.sprite("fog/#{file}", true)
      @x = @y = 0.0
      @sx, @sy = sx, sy
      @color = Gosu::Color.new(a, r, g, b)
    end
    def update
      @x += @sx
      @y += @sy
      if @x > 1024
        @x = 0.0
      elsif @x < 0
        @x = 1024.0
      end
      if @y > 768.0
        @y = 0
      elsif @y < 0
        @y = 768.0
      end
    end
    def draw
      @img.draw(@x, @y, EH::FOG_Z, 1, 1, @color)
      if @sx != 0
        @img.draw(@x-@img.width, @y, EH::FOG_Z, 1, 1, @color)
      end
      if @sy != 0
        @img.draw(@x, @y-@img.height, EH::FOG_Z, 1, 1, @color)
      end
      if @sx != 0 and @sy != 0
        @img.draw(@x-@img.width, @y-@img.height, EH::FOG_Z, 1, 1, @color)
      end
    end
    
  end
  
end
