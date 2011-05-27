
require_relative "gui/select_spell.rb"
require_relative "gui/select_item.rb"

module EH::Game::Combat
  
  class GUI
    
    attr_reader :attacking, :casting, :using
    
    def initialize
      @x = 0
      @y = 544
      @z = 5000
      @bg = EH.sprite("gui/battle_infoback")
      @w = {} # Currently shown windows
      @ready = []
      @paused = false
      @chosen = @choose = nil
      @attacking = []
      @casting = []
      @using = []
    end
      
    def push(type, *parms)
      case type
      when :ready
        ready(parms)
      end
    end
      
    def open_info(obj, x, y)
      if @choose and !@chosen
        @chosen = obj
      else
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
    end
      
    def update
      @w.each_value { |w|
        w.update
        if w.remove?
          @w.delete(@w.key(w))
        end
      }
      if @choose and @chosen
        @choose.call
      end
    end
      
    def draw
      @bg.draw(@x, @y, @z, 1024/@bg.width.to_f, 224/@bg.height.to_f)
      @w.each_value { |w|
        w.draw
      }
    end
    
    def paused?
      return @paused
    end
    
    def attacked
      @attacking = []
    end
    
    def spell_cast
      @casting = []
    end
    
    def item_used
      @using = []
    end
    
    def abort_action(actor)
      @paused = false
      @choose = nil
      @chosen = nil
      @w[:select_spell].close! if @w[:select_spell]
      @w[:select_item].close! if @w[:select_item]
      setup_ready_actions(actor)
    end
    
    private
    
    def attack(attacker, target)
      @attacking = [attacker, target]
      shift_ready
      abort_actions(@ready.first)
    end
    
    def cast(attacker, target, spell)
      @casting = [attacker, target, spell]
      shift_ready
      abort_actions(@ready.first)
    end
    
    def use(attacker, target, item)
      @using = [attacker, target, item]
      shift_ready
      abort_actions(@ready.first)
    end
    
    def ready(ary)
      actor = ary.first
      char = actor.character
      if @ready.empty?
        @w[:ready] = EH::GUI::Window.new(768, @y, 256, 224, char.name, false, "gui/container_background")
        setup_ready_actions(actor)
      end
      @ready.push(actor)
    end
    
    def shift_ready
      if @ready.empty?
        @w.delete(:ready)
      else
        @ready.shift
        if @ready.empty?
          @w[:ready].close!
        else
          @w[:ready].title = @ready.first.character.name
          setup_ready_actions(@ready.first.character)
        end
      end
    end
    
    def setup_ready_actions(actor)
      w = @w[:ready]
      w.empty
      w.add(:attack, EH::GUI::Button.new(8, 8, 240, 32, EH::Trans.menu(:attack), lambda {open_attack(actor)}))
      w.add(:skill, EH::GUI::Button.new(8, 48, 240, 32, EH::Trans.menu(:magic), lambda {open_spell(actor)}))
      w.add(:item, EH::GUI::Button.new(8, 88, 240, 32, EH::Trans.menu(:item), lambda {open_item(actor)}))
    end
    
    def open_attack(actor)
      @paused = true
      @choose = lambda { attack(actor, @chosen) }
      open_abort(actor)
    end
    
    def open_spell(actor)
      @paused = true
      if EH.config[:combat_gui_spell_select_window_x]
        x = EH.config[:combat_gui_spell_select_window_x]
      else
        x = 192
      end
      if EH.config[:combat_gui_spell_select_window_y]
        y = EH.config[:combat_gui_spell_select_window_y]
      else
        y = 192
      end
      @w.store(:select_spell, SelectSpell.new(x, y, actor))
      @w[:select_spell].parent = self
      open_abort(actor)
    end
    
    def open_item(actor)
      puts("STUB: GUI.open_item")
      @paused = true
      open_abort(actor)
    end
    
    def open_abort(actor)
      @w[:ready].empty
      @w[:ready].add(:abort, EH::GUI::Button.new(8, 8, 240, 32, EH::Trans.menu(:abort), lambda {abort_action(actor)}))
    end
    
  end

end
