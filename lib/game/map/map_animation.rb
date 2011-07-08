
module EH::Game
  
  class MapAnimation < MapObject
    
    def initialize(anim, x, y)
      super(x, y, {})
      @anim = EH.anim(anim)
      @anim.play(x, y, @z)
    end
    
    def update
    end
    
    def draw(xoff, yoff)
      @anim.x = @x + xoff
      @anim.y = @y + yoff
      @anim.draw
      if @anim.remove?
        @dead = true
      end
    end
    
  end
  
end
