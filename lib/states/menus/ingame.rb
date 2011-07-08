
module EH::States
  
  class IngameMenu < State
    include EH::GUI
    include EH
    def initialize(window, party)
      super(window)
      @background = EH.sprite("menu/ingame_background")
      @w = EH::GUI::Window.new(0, 0, 1024, 768, Trans.menu(:menu))
      @w.add(:items, Button.new(32, 32, 224, 32, Trans.menu(:items), lambda {}))
      @w.add(:equip, Button.new(32, 96, 224, 32, Trans.menu(:equipment), lambda { @window.advance(EquipMenu.new(@window, self, party)) }))
      @w.add(:skills, Button.new(32, 160, 224, 32, Trans.menu(:skills), lambda {}))
      @w.add(:alchemy, Button.new(32, 224, 224, 32, Trans.menu(:botany), lambda { @window.advance(AlchemyMenu.new(@window, self, party)) }))
      @w.add(:magic, Button.new(32, 284, 224, 32, Trans.menu(:magic), lambda { @window.advance(MagicMenu.new(@window, self, party)) }))
      @w.add(:save, Button.new(32, 552, 224, 32, Trans.menu(:save), lambda {}))
      @w.add(:load, Button.new(32, 616, 224, 32, Trans.menu(:load), lambda {}))
      @w.add(:options, Button.new(32, 680, 224, 32, Trans.menu(:options), lambda {}))
    end
    def update
      if @window.pressed?(Gosu::KbEscape) or @w.remove?
        @window.load
      end
      update_cursor
      @w.update
    end
    def draw
      @background.draw(0, 0, 0)
      @w.draw
      draw_cursor
    end
  end
  
end
