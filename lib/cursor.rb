
module EH
  
  class Cursor
    def initialize
      @cursor = EH::Sprite.new(EH.window, "cursors/normal")
      clear
    end
    
    def update(x, y)
      @x, @y = x, y
    end
    
    def draw
      if !@x
        @x = 0
      end
      if !@y
        @y = 0
      end
      @cursor.draw(@x, @y, EH::CURSOR_Z)
      if @sprite
        @sprite.draw(@x+4, @y+8, EH::CURSOR_Z-1)
      end
    end
    
    def attach(sprite)
      @sprite = sprite
    end
    
    def clear
      @sprite = nil
    end
    
    def empty?
      return @sprite == nil
    end
    
  end
  
end
