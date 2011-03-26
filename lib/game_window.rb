
# Main state logic - obviously

module EH
  class GameWindow < Gosu::Window
    attr_reader :state
    include States
    def initialize
      super(1024, 768, false)
      self.caption = "Ewige Hoffnung - v#{EH::VERSION}"
      EH.window = self
      @state = StartMenu.new(self)
      @unpress = []
    end
    def update
      @state.update
      unpress
    end
    def draw
      @state.draw
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
