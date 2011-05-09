
module EH::GUI
  
  # Small menu available by rightclicking on the map
  class ContextMenu < Element
    def initialize(x, y, obj=nil)
      super(x, y, 128, items(obj) * 24)
      if @x + @w > 1024
        @x = 1024 - @w
      end
      @buttons = {}
      setup_defaults(obj)
    end
    def update
      super
      @buttons.each_value { |but|
        but.update
      }
    end
    def draw
      @buttons.each_value { |but|
        but.draw
      }
    end
    
    private
    
    def items(obj)
      if obj
        return 3
      else
        return 2
      end
    end
    def setup_defaults(obj)
      if obj
        if obj.class == EH::Game::MapNPC
          label = obj.gamename
        else
          label = obj.name
        end
      else
        label = EH::Trans.menu(:ground)
      end
      @buttons.store(:label, Textfield.new(@x, @y, @w, 24, label, 24))
      @buttons.store(:move, Button.new(@x, @y+24, @w, 24, EH::Trans.menu(:walk_here), lambda { puts("STUB: move_to #{@x.to_i}|#{@y.to_i}"); @remove = true }, true, :left))
    end
  end
    
end