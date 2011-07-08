
module EH::States
  
  class MagicMenu < State
    include EH::GUI
    include EH
    def initialize(window, previous, party)
      super(window)
      @previous = previous
      @party = party
      @background = EH.sprite("menu/ingame_background")
      @w = EH::GUI::Window.new(0, 0, 1024, 768, Trans.menu(:magic))
      @w.add(:charselect, CharSelector.new(32, 32, party))
    end
    def update
      super
      if @window.pressed?(Gosu::KbEscape) or @w.remove?
        @window.advance(@previous)
      end
      @w.update
      if @w.get(:charselect).changed?
      end
    end
    def draw
      @background.draw(0, 0, 0)
      @w.draw
      draw_cursor
    end
  end
  
end
