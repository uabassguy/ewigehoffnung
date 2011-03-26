
require "gui/base.rb"

module EH::GUI
  
  class CharSelector < Element
    attr_reader :index
    def initialize(x, y, party, w=256, h=32)
      super(x, y, w, h)
      @index = 0
      @changed = false
      @party = party
      @background = EH::Sprite.new(EH.window, "gui/charselect_background")
      @font = Gosu::Font.new(EH.window, EH::DEFAULT_FONT, 24)
      @left = Button.new(x, y, 32, 32, "<", lambda {left}, false)
      @right = Button.new(x+w-32, y, 32, 32, ">", lambda {right}, false)
    end
    def update(window)
      @left.update(window)
      @right.update(window)
    end
    def left
      @index -= 1
      if @index < 0
        @index = @party.members.size-1
      end
      @changed = true
    end
    def right
      @index += 1
      if @index >= @party.members.size
        @index = 0
      end
      @changed = true
    end
    def changed?
      if @changed
        @changed = false
        return true
      else
        return false
      end
    end
    def draw
      @background.img.draw(@x, @y, EH::GUI_Z + 9, @w/@background.width, @h/@background.height)
      @font.draw(@party.members[@index].name, @x+(@w/2)-(@font.text_width(@party.members[@index].name)/2), @y+(@h/6), EH::GUI_Z + 10, 1, 1, Gosu::Color::BLACK)
      @left.draw
      @right.draw
    end
  end
  
end
