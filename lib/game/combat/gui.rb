
module EH::Game::Combat
  
  class GUI
    def initialize
      @x = 0
      @y = 544
      @z = 5000
      @bg = EH.sprite("gui/battle_infoback")
      @w = {} # Currently shown windows
    end
      
    def push(type, *parms)
      puts("STUB: GUI.push(#{type}, #{parms.inspect})")
    end
      
    def open_info(obj, x, y)
      if EH.config[:combat_gui_info_window_x]
        x = EH.config[:combat_gui_info_window_x]
      end
      if EH.config[:combat_gui_info_window_y]
        y = EH.config[:combat_gui_info_window_y]
      end
      @w[:info] = EH::GUI::Window.new(EH.window.state, x, y, 320, 256, "Info", true, "gui/container_background", true)
      @w[:info].add(:text, EH::GUI::Textfield.new(8, 8, 304, 240, "#{obj}"))
      @w[:info].title = "#{EH::Trans.enemy(obj.data.name)}"
      @w[:info].save_pos(:combat_gui_info_window_x, :combat_gui_info_window_y)
    end
      
    def update
      @w.each_value { |w|
        w.update
        if w.remove?
          @w.delete(@w.key(w))
        end
      }
    end
      
    def draw
      @bg.draw(@x, @y, @z, 1024/@bg.width.to_f, (768-544)/@bg.height.to_f)
      @w.each_value { |w|
        w.draw
      }
    end
  end

end
