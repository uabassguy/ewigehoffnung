
module EH::GUI
  
  # Small menu available by rightclicking on the map
  class ContextMenu < Element
    def initialize(x, y, obj=nil)
      super(x, y, 128, items(obj) * 24)
      @zoff = 10000
      if @x + @w > 1024
        @x = 1024 - @w
      end
      @buttons = {}
      setup_defaults(obj)
      @buttons.each_value { |but|
        but.zoff = @zoff
      }
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
    
    def in_window?
      EH.window.state.osd.each_value { |w|
        if EH.inside?(@x, @y, w.x, w.y, w.x+w.w, w.y+w.h)
          return true
        end
      }
      return false
    end
    
    def magic_window(p)
      EH.window.state.osd.store(:magic, EH::Game::OSD::Magic.new(@x-320, @y-240, p, p));
    end
    
    def setup_defaults(obj)
      if in_window?
        return
      end
      npc = player = false
      if obj
        if obj.class == EH::Game::MapNPC
          label = obj.gamename
          npc = true
        elsif obj.class == EH::Game::Player
          player = true
          label = EH::Trans.menu(:you)
        else
          label = obj.name
        end
      else
        label = EH::Trans.menu(:ground)
      end
      
      p = EH.window.state.player
      
      @buttons.store(:label, Textfield.new(@x, @y, @w, 24, label, 24))
      
      if !player
        if npc
          @buttons.store(:talk_to,
            Button.new(@x, @y+(@buttons.size*24), @w, 24, EH::Trans.menu(:talk_to),
              lambda { puts("STUB: talk_to"); p.find_path_to(@x.to_i/32, (@y.to_i/32) - (p.y < obj.y ? 1 : -1)); @remove = true }, true, :left))
        else
          @buttons.store(:move,
            Button.new(@x, @y+(@buttons.size*24), @w, 24, EH::Trans.menu(:walk_here),
              lambda { p.find_path_to(@x.to_i/32, @y.to_i/32); @remove = true }, true, :left))
          if !EH.window.state.map.current.passable?(@x, @y) or (obj and !obj.through)
            # TODO left/right
            if !obj
              obj = [@x, @y] # i <3 ruby
            end
            # a* cant find a path to a blocked tile, so shift the position away a bit
            @buttons[:move].proc = lambda { p.find_path_to(@x.to_i/32, (@y.to_i/32) - (p.y < obj.y ? 1 : -1)); @remove = true }
            # TODO check again if it works, the player *must* move
          end
        end
      end
      if !EH.window.state.osd.has_key?(:magic)
        @buttons.store(:magic,
          Button.new(@x, @y+(@buttons.size*24), @w, 24, EH::Trans.menu(:magic),
            lambda { magic_window(p); @remove = true}, true, :left))
        if npc
          @buttons[:magic].proc = lambda { puts("STUB: othermagic"); @remove = true }
        end
      end
      if $DEBUG and obj
        @buttons.store(:debug_inspect,
          Button.new(@x, @y+(@buttons.size*24), @w, 24, "inspect", lambda { awesome_print(obj); @remove = true }, true, :left))
      end
    end
      
  end
    
end