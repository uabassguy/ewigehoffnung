
require_relative "map_object.rb"

module EH::Game
  class Player < MapNPC
    include Gosu
    def initialize(x=0, y=0)
      super(x, y, {:file => EH.window.state.party.player.charset})
      @speed = 2
      @x, @y = x, y
      @name = "player"
      @gamename = EH.window.state.party.player.name
    end
    def update
      window = EH.window
      if @dx == 0 and @dy == 0
        if window.button_down?(KbLeft)
          @dx = -32;
          @dy = 0;
          destroy_goal
        elsif window.button_down?(KbRight)
          @dx = 32;
          @dy = 0;
          destroy_goal
        elsif window.button_down?(KbUp)
          @dx = 0;
          @dy = -32;
          destroy_goal
        elsif window.button_down?(KbDown)
          @dx = 0;
          @dy = 32;
          destroy_goal
        end
      end
      if window.pressed?(KbSpace) or window.pressed?(KbReturn) or window.pressed?(KbEnter)
        update_trigger
      end
      super
    end
  end
end
