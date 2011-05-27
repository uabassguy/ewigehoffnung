
require_relative "base.rb"

module EH::GUI
  
  class CharSelector < Element
    attr_reader :index
    def initialize(x, y, party, w=256, h=32)
      super(x, y, w, h)
      @index = 0
      @changed = false
      @party = party
      @background = EH.sprite("gui/charselect_background")
      @font = EH.font(EH::DEFAULT_FONT, 24)
      @left = Button.new(x, y, 32, 32, "<", lambda {left}, false)
      @right = Button.new(x+w-32, y, 32, 32, ">", lambda {right}, false)
    end
    def update
      @left.xoff = @right.xoff = @xoff
      @left.yoff = @right.yoff = @yoff
      @left.update
      @right.update
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
      @background.draw(@x+@xoff, @y+@yoff, EH::GUI_Z + 9, @w/@background.width, @h/@background.height)
      @font.draw(@party.members[@index].name, @x+@xoff+(@w/2)-(@font.text_width(@party.members[@index].name)/2), @y+@yoff+(@h/6), EH::GUI_Z + 10, 1, 1, Gosu::Color::BLACK)
      @left.draw
      @right.draw
    end
  end
  
end
