
module EH::GUI
  
  # Allows EH::GUI::Elements to be placed into a 32x32 px grid.
  # Elements can be selected and dragged
  class Grid < Element
    
    attr_reader :selected
    
    def initialize(x, y, tx, ty, in_classes=[])
      super(x, y, tx*32, ty*32)
      @classes = in_classes
      @grid = Array.new(tx) { Array.new(ty) }
      @bg = EH.sprite("gui/container_background")
      @tile = EH.sprite("gui/tile_32")
      @hl = EH.sprite("gui/tile_32_highlight")
      @selected = nil
      @highlight = nil
      @hovered = nil
    end
    
    def update
      if EH.mouse_inside?(@x+@xoff, @y+@yoff, @x+@xoff+@w, @y+@yoff+@h)
        if EH.window.pressed?(Gosu::MsLeft)
          @highlight = mouse_to_tile(EH.window.mouse_x, EH.window.mouse_y)
          @selected = get_at(@highlight.x, @highlight.y)
        else
          @hovered = mouse_to_tile(EH.window.mouse_x, EH.window.mouse_y)
        end
      else
        @hovered = nil
        if EH.window.button_down?(Gosu::MsLeft)
          @selected = nil
          @highlight = nil
        end
      end
    end
    
    def draw
      x = @x + @xoff
      y = @y + @yoff
      @bg.draw(x, y, EH::GUI_Z + @zoff, @w/@bg.width.to_f, @h/@bg.height.to_f)
      @grid.each { |col|
        col.each { |tile|
          tile.icon.draw(x, y, EH::GUI_Z + @zoff + 1) if tile
          @tile.draw(x, y, EH::GUI_Z + @zoff + 1)
          y += 32
        }
        x += 32
        y = @y + @yoff
      }
      if @selected and @highlight
        @hl.draw(@x+@xoff+@highlight.x*32, @y+@yoff+@highlight.y*32, EH::GUI_Z + @zoff + 2)
      end
      if @hovered and (!@highlight or !(@hovered.x == @highlight.x and @hovered.y == @highlight.y))
        @hl.draw(@x+@xoff+@hovered.x*32, @y+@yoff+@hovered.y*32, EH::GUI_Z + @zoff + 2)
      end
    end
    
    # Adds obj to the grid at the next free position
    # Returns the position where obj was inserted
    def add(obj)
      if @classes.include?(obj.class)
        x = 0
        @grid.each { |col|
          y = 0
          col.each { |tile|
            if tile == nil
              @grid[x][y] = obj
              return [x, y]
            end
            y += 1
          }
          x += 1
        }
      end
      return [0, 0]
    end
    
    # Adds obj at the given position, overwriting any other value
    # Calls add() if the given position is invalid
    def add_at(obj, tx, ty)
      if @classes.include?(obj.class)
        @grid[tx][ty] = obj
      end
    rescue NoMethodError
      warn("WARNING: Tried to insert element at invalid index (#{obj}, #{tx}|#{ty})")
      add(obj)
    end
    
    def get_at(tx, ty)
      return @grid[tx][ty]
    rescue NoMethodError
      return nil
    end
    
    def mouse_to_tile(mx, my)
      x = (mx - @x - @xoff).to_i / 32
      y = (my - @y - @yoff).to_i / 32
      return [x, y]
    end
    
    def empty?
      @grid.each { |col|
        col.each { |tile|
          return false if tile
        }
      }
      return true
    end
    
    def clear
      @grid = Array.new(@w/32) { Array.new(@h/32) }
    end
    
  end
  
end
