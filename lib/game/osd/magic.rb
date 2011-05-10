
module EH::Game
  module OSD
  
    class Magic < EH::GUI::Window
      def initialize(x, y, caster=EH::Game.party.player, target=nil)
        if x + 640 > 1024
          x = 386
        end
        if y + 480 > 768
          y = 264
        end
        super(EH.window.state, x, y, 640, 480, EH::Trans.menu(:magic), true, "osd/magic_bg", true)
        @caster, @target = caster, target
        add(:char, EH::GUI::CharSelector.new(16, 16, @state.party))
      end
    end
  
  end  
end
