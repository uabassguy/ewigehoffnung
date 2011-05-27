
module EH::Game::Combat
  
  class SelectSpell < EH::GUI::Window
    
    def initialize(x, y, actor)
      super(x, y, 384, 256, EH::Trans.menu(:select_spell), true, "gui/container_background", true)
      @close.proc = lambda { close!; @parent.abort_action(actor) }
      save_pos(:combat_gui_spell_select_window_x, :combat_gui_spell_select_window_y)
      add(:container, EH::GUI::Container.new(8, 8, 184, 240, 24))
      add(:info, EH::GUI::Textfield.new(200, 8, 176, 240, ""))
      setup_skill_select(actor)
    end
    
    private
    
    def setup_skill_select(actor)
      char = actor.character
      c = get(:container)
      y = 8
      char.spells.each { |spell, level|
        c.add(EH::GUI::Button.new(0, y, c.w-24, c.ch, EH::Trans.spell(spell.name), lambda { clicked(spell) }))
        y += c.ch
      }
    end
    
    def clicked(spell)
      get(:info).text = EH::Trans.spell("#{spell.name}_desc".to_sym)
    end
    
  end
  
end
