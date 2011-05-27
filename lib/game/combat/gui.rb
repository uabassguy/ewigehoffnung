
module EH::Game::Combat
  
  class GUI
    def initialize
      @x = 0
      @y = 544
      @z = 5000
      @bg = EH.sprite("gui/battle_infoback")
      @w = {} # Currently shown windows
      @ready = []
    end
      
    def push(type, *parms)
      case type
      when :ready
        ready(parms)
      end
    end
      
    def open_info(obj, x, y)
      if EH.config[:combat_gui_info_window_x]
        x = EH.config[:combat_gui_info_window_x]
      end
      if EH.config[:combat_gui_info_window_y]
        y = EH.config[:combat_gui_info_window_y]
      end
      @w[:info] = EH::GUI::Window.new(x, y, 320, 256, "Info", true, "gui/container_background", true)
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
      @bg.draw(@x, @y, @z, 1024/@bg.width.to_f, 224/@bg.height.to_f)
      @w.each_value { |w|
        w.draw
      }
    end
    
    private
    
    def ready(ary)
      actor = ary.first
      char = actor.character
      if @ready.empty?
        @w[:ready] = EH::GUI::Window.new(768, @y, 256, 224, char.name, false, "gui/container_background")
        setup_ready_skills
      end
      @ready.push(actor)
    end
    
    def shift_ready
      if @ready.empty?
        @w.delete(:ready)
      else
        @ready.shift
        if @ready.empty?
          @w[:ready].close
        else
          @w[:ready].title = @ready.first.character.name
          setup_ready_skills
        end
      end
    end
    
    def setup_ready_skills
      w = @w[:ready]
      w.empty
      w.add(:attack, EH::GUI::Button.new(8, 8, 240, 32, EH::Trans.menu(:attack), lambda { open_attack }))
      w.add(:skill, EH::GUI::Button.new(8, 48, 240, 32, EH::Trans.menu(:skill), lambda { open_skill }))
      w.add(:item, EH::GUI::Button.new(8, 88, 240, 32, EH::Trans.menu(:item), lambda { open_item }))
    end
    
    def open_attack
      puts("STUB: GUI.open_attack")
      shift_ready
    end
    
    def open_skill
      puts("STUB: GUI.open_skill")
      shift_ready
    end
    
    def open_item
      puts("STUB: GUI.open_item")
      shift_ready
    end
    
  end

end
