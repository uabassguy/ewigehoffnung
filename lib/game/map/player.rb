
require "game/map/map_object.rb"

module EH::Game
  class Player < MapObject
    include Gosu
    def initialize(x=0, y=0)
      super(x, y, {:file => EH.window.state.party.player.charset})
      @speed = 2
      @x, @y = x, y
      @name = "player"
    end
    def update
      window = EH.window
      if @dx == 0 and @dy == 0
        if window.button_down?(KbLeft)
          @dx = -32;
          @dy = 0;
        elsif window.button_down?(KbRight)
          @dx = 32;
          @dy = 0;
        elsif window.button_down?(KbUp)
          @dx = 0;
          @dy = -32;
        elsif window.button_down?(KbDown)
          @dx = 0;
          @dy = 32;
        end
      end
      if window.pressed?(KbSpace) or window.pressed?(KbReturn) or window.pressed?(KbEnter)
        update_trigger
      end
      super
    end
  end
end
