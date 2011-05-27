
module EH::Game::Combat
  
  class SelectSpell < EH::GUI::Window
    
    def initialize(x, y, actor)
      super(x, y, 512, 256, EH::Trans.menu(:select_spell), true, "gui/container_background", true)
      @close.proc = lambda { close!; @parent.abort_action(actor) }
      save_pos(:combat_gui_spell_select_window_x, :combat_gui_spell_select_window_y)
      setup_skill_select(actor)
    end
    
    private
    
    def setup_skill_select(actor)
      char = actor.character
      y = 8
    end
    
  end
  
end
