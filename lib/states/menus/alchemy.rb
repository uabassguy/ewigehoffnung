
module EH::States
  
  class AlchemyMenu < State
    
    include EH
    include EH::GUI
    
    def initialize(window, previous, party)
      super(window)
      @previous = previous
      @party = party
      @background = EH.sprite("menu/ingame_background")
      @w = EH::GUI::Window.new(0, 0, 1024, 768, Trans.menu(:botany))
      @w.add(:charselect, CharSelector.new(32, 32, party))
      @w.add(:experience, Textfield.new(320, 32, 256, 32, "#{Trans.menu(:experience)}: #{@party.members[@w.get(:charselect).index].skills.level_to_s(Game.find_skill(:botany))}", 24, :center))
      @w.add(:recipies_text, Textfield.new(32, 96, 256, 32, Trans.menu(:recipies), 24, :center))
      @w.add(:recipies, Container.new(32, 128, 256, 584, 24))
      @w.add(:items_text, Textfield.new(736, 96, 256, 32, Trans.menu(:items), 24, :center))
      @w.add(:items, Inventory.new(736, 128, 256, 584, @party.members[@w.get(:charselect).index], [:herb, :food, :poison], 24))
      @w.add(:info_header, Textfield.new(320, 480, 384, 200, "", 24, :center))
      @w.add(:info, Textfield.new(320, 512, 384, 200, ""))
    end
    
    def update
      super
      if @window.pressed?(Gosu::KbEscape) or @w.remove?
        @window.advance(@previous)
      end
      @w.update
      if @w.get(:charselect).changed?
        char = @party.members[@w.get(:charselect).index]
        @w.get(:experience).text = "#{Trans.menu(:experience)}: #{char.skills.level_to_s(Game.find_skill(:botany))}"
        @w.get(:items).inventory = char.inventory
      end
      if @w.get(:items).changed?
        @w.get(:info_header).text = Trans.item(@w.get(:items).selected.name)
        @w.get(:info).text = Trans.item("#{@w.get(:items).selected.name}_desc")
      end
    end
    
    def draw
      @background.draw(0, 0, 0)
      @w.draw
      draw_cursor
    end
    
  end
  
end
