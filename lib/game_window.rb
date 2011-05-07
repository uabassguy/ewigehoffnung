
# Main state logic - obviously

module EH
  class GameWindow < Gosu::Window
    attr_accessor :state
    include States
    def initialize
      super(1024, 768, false)
      self.caption = "Ewige Hoffnung - v#{EH::VERSION}"
      EH.window = self
      @state = StartMenu.new(self)
      @unpress = []
      @font = EH.font(EH::DEFAULT_FONT, 20)
      @bg = EH.sprite("pixel", true)
    end
    def update
      @state.update
      unpress
      self.caption = "Ewige Hoffnung - v#{EH::VERSION} - #{Gosu.fps} FPS"
    end
    def draw
      @state.draw
      if $DEBUG
        @bg.draw(16, 16, 999999, 160, 48, 0x99000000)
        @font.draw("Mouse: #{mouse_x.to_i}|#{mouse_y.to_i}", 32, 32, 999999)
      end
    end
    def advance(state)
      @state.finish
      @state = state
    end
    def save
      @saved = @state
    end
    def load
      @state = @saved
    end
    def pressed?(key)
      p = button_down?(key)
      if p
        if @unpress.include?(key)
          p = false
        else
          @unpress.push(key)
        end
      end
      return p
    end
    def unpress
      @unpress.each { |key|
        if !button_down?(key)
          @unpress.delete(key)
        end
      }
    end
  end
end
