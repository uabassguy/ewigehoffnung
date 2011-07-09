
module EH::GUI
  
  class Grid < Element
    
    def initialize(x, y, tx, ty, in_classes=[], in_types=[])
      super(x, y, tx*32, ty*32)
      @classes = in_classes
      @types = in_types
      @grid = Array.new(tx) { Array.new(ty) }
      @bg = EH.sprite("gui/container_background")
      @tile = EH.sprite("gui/tile_32")
    end
    
    def update
    end
    
    def draw
      x = @x + @xoff
      y = @y + @yoff
      @bg.draw(x, y, EH::GUI_Z + @zoff, @w/@bg.width.to_f, @h/@bg.height.to_f)
      @grid.each { |col|
        col.each { |tile|
          @tile.draw(x, y, EH::GUI_Z + @zoff + 1)
          y += 32
        }
        x += 32
        y = @y + @yoff
      }
    end
    
    def push(obj, id)
    end
    
    def add(obj, id, tx, ty)
    end
    
    def get(id)
    end
    
    def get_at(tx, ty)
      return @grid[tx][ty]
    end
    
    def mouse_to_tile(mx, my)
      return []
    end
    
    def empty?
      num = 0
      @grid.each { |col|
        col.each { |tile|
          num += 1 if tile
        }
      }
      return num
    end
    
  end
  
end
