
# gui logic

module EH::GUI
  class Window
    attr_reader :state
    # height includes titlebar
    def initialize(state, x, y, w, h, close=true, move=false, z=-1)
      @state = state
      @x, @y, @w, @h, @z = x, y, w, h, z
      if @z < 0
        @z = EH::GUI_Z
      end
      @elements = {}
      @bar = [
        EH::Sprite.new(state.window, "gui/bar_left", true),
        EH::Sprite.new(state.window, "gui/bar_center", true),
        EH::Sprite.new(state.window, "gui/bar_right", true)
      ]
      @title = @titlefont = nil
      @remove = false
      if close
        @close = ImageButton.new(@w-24, @y, "button_close", lambda { @remove = true })
      else
        @close = nil
      end
      @move = move
    end
    def get(sym)
      return @elements[sym]
    end
    def close
      @remove = true
    end
    def remove?
      return @remove
    end
    def title=(str)
      @titlefont = Gosu::Font.new(EH.window, EH::DEFAULT_FONT, 24)
      @title = str
    end
    def add(name, el)
      @elements.store(name, el)
    end
    def update
      @elements.each_value { |el|
        el.update(self)
        if el.remove?
          @elements.delete(@elements.key(el))
        end
      }
      @close.update(self) if @close
    end
    def draw
      @elements.each_value { |el|
        el.xoff = @x
        el.yoff = @y + 24 # titlebar
        el.draw
      }
      @bar[0].draw(@x, @y, @z)
      @bar[1].img.draw(@x+16, @y, @z, (@w-32)/@bar[1].width)
      @bar[2].draw(@x+@w-16, @y, @z)
      @titlefont.draw(@title, @x+(@w/2)-(@titlefont.text_width(@title)/2), @y+1, @z+1, 1, 1, Gosu::Color::BLACK)
      @close.draw if @close
    end
  end
  
  class Element
    attr_accessor :xoff, :yoff
    attr_reader :x, :y, :w, :h
    # x and y are relative to the windows topleft corner plus title bar
    def initialize(x, y, w, h)
      @remove = false
      @xoff = @yoff = 0
      @x, @y, @w, @h = x, y, w, h
    end
    def update(window)
    end
    def draw
    end
    def remove?
      return @remove
    end
  end
  
  # scrollable
  class Container < Element
    def initialize(x, y, w, h, ch)
      super(x, y, w, h)
      @scrollbar = Scrollbar.new(x+w-24, y, 24, h)
      @ch = ch
      @content_offset = 0
    end
    def update(window)
      @scrollbar.update(window)
      @content_offset = @scrollbar.offset * -@ch
    end
    def draw
      @scrollbar.draw
    end
  end
  
  class Scrollbar < Element
    include Gosu
    attr_accessor :sh
    attr_reader :h
    def initialize(x, y, w, h)
      super
      @bg = EH::Sprite.new(EH.window, "gui/scrollbar_background")
      @scroller = EH::Sprite.new(EH.window, "gui/scroller")
      @held = false
      @sy = @y
      @sh = 48
    end
    def offset
      return ((@sy-@y)/((@y)-(@y+@h-@sh)+1))*-100
    end
    def update(window)
      x = EH.window.mouse_x
      y = EH.window.mouse_y
      if EH.inside?(x, y, @x, @sy, @x+@w, @sy+@sh) and EH.window.button_down?(MsLeft) and !@held
        @held = true
        @offset = @sy-y
      end
      if @held
        @sy = y + @offset
        if @sy < @y
          @sy = @y
        elsif @sy+@sh > @y+@h
          @sy = @y+@h-@sh-1
        end
        if !EH.window.button_down?(MsLeft)
          @held = false
        end
      end
    end
    def draw
      @bg.img.draw(@x, @y, EH::GUI_Z + 14, @w/@bg.width, @h/@bg.height.to_f)
      @scroller.img.draw(@x, @sy, EH::GUI_Z + 15, 1, @sh/@scroller.height.to_f)
    end
  end
  
end

require "gui/button.rb"