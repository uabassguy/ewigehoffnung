
#--
# Main state logic - obviously

if EH.config[:opengl]
  require_relative "ext/shader.rb"
end

require_relative "particles.rb"
require_relative "animation.rb"

module EH
  class GameWindow < Gosu::Window
    attr_accessor :state
    include States
    def initialize
      super(1024, 768, false)
      self.caption = "Ewige Hoffnung - v#{EH::VERSION}"
      EH.window = self
      EH.particles = EH::Parse.particles
      EH.animations = EH::Parse.animations
      @state = StartMenu.new(self)
      @unpress = []
      @font = EH.font(EH::DEFAULT_FONT, 20)
      @bg = EH.sprite("pixel", true)
      if (EH.config[:contrast] != 1.0 and EH.config[:opengl])
        @contrast = Shader.new(self, "glsl/contrast")
        @contrast["contrast"] = EH.config[:contrast]
      end
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
      if @contrast
        @contrast.apply
      end
    end
    # Advance to the next state
    # 
    # Requires an EH::States::State instance
    def advance(state)
      @state.finish
      @state = state
    end
    # Save current state so we can go back to it later
    #
    # The GameState is saved when switching to a MenuState
    def save
      @saved = @state
    end
    def load
      @state = @saved
    end
    # Checks if a specific key is pressed
    # 
    # Only returns true again if the key was held loose
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
