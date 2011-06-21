
# gui logic

module EH::GUI
  
  class Window # make hash?
    attr_reader :state, :x, :y, :w, :h, :close
    # height includes titlebar
    attr_accessor :xoff, :yoff, :zoff # completely unused, just used for windows in windows
    attr_accessor :parent
    def initialize(x, y, w, h, titlestr, close=true, bg=nil, move=false, z=-1)
      @state = EH.window.state
      @xoff = @yoff = @zoff = 0
      if bg
        @bg = EH.sprite(bg)
      else
        @bg = nil
      end
      @x, @y, @w, @h, @z = x, y, w, h, z
      if @z < 0
        @z = EH::GUI_Z
      end
      @elements = {}
      @bar = [
        EH.sprite("gui/bar_left", true),
        EH.sprite("gui/bar_center", true),
        EH.sprite("gui/bar_right", true)
      ]
      @titlefont = EH.font("arial", 24)
      @title = titlestr
      @remove = false
      if close
        @close = ImageButton.new(@w-24, @y, "gui/button_close", lambda { @remove = true })
      else
        @close = nil
      end
      @move = move
      @changed = false
      @dragging = false
      @parent = nil
    end
    def empty
      @elements = {}
    end
    def include?(sym)
      return get(sym) != nil
    end
    def [](sym)
      return get(sym)
    end
    def get(sym)
      return @elements[sym]
    end
    def close!
      @remove = true
    end
    def remove?
      return @remove
    end
    # Set the title
    def title=(str)
      @title = str
    end
    # Add an element
    def add(name, el)
      @elements.store(name, el)
    end
    
    # Enable position saving
    def save_pos(xsym, ysym)
      @xsym, @ysym = xsym, ysym
      @save_pos = true
    end
    
    def update
      @elements.each_value { |el|
        el.update
        if el.remove?
          @elements.delete(@elements.key(el))
        end
      }
      if @close
        @close.x, @close.y, @close.zoff = @x+@w-24, @y, @zoff
        @close.update
      end
      if @move
        m = [EH.window.mouse_x, EH.window.mouse_y]
        if EH.inside?(m.x, m.y, @x, @y, @x+@w-24, @y+24) or @dragging
          if EH.window.button_down?(Gosu::MsLeft)
            if !@dragging
              @dragging = true
              @dragx = m.x - @x
              @dragy = m.y - @y
            else
              @x = m.x - @dragx
              @y = m.y - @dragy
            end
          else
            @dragging = false
          end
        end
      end
      if @dragging
        if @x > 1024 - @w
          @x = 1024 - @w
        elsif @x < 0
          @x = 0
        end
        if @y > 744
          @y = 744
        elsif @y < 0
          @y = 0
        end
      end
      if @save_pos
        EH.config[@xsym] = @x
        EH.config[@ysym] = @y
      end
    end
    
    def draw
      @bg.draw(@x, @y+24, @z, @w/@bg.width.to_f, @h/@bg.height.to_f) if @bg
      @elements.each_value { |el|
        el.xoff = @x
        el.yoff = @y + 24 # titlebar
        el.draw
      }
      @bar[0].draw(@x, @y, @z)
      @bar[1].draw(@x+16, @y, @z, (@w-32)/@bar[1].width)
      @bar[2].draw(@x+@w-16, @y, @z)
      @titlefont.draw(@title, @x+(@w/2)-(@titlefont.text_width(@title)/2), @y+1, @z+1, 1, 1, Gosu::Color::BLACK)
      @close.draw if @close
    end
  end
  
  class Element
    attr_accessor :x, :y, :xoff, :yoff, :zoff, :w, :h
    # x and y are relative to the windows topleft corner plus title bar
    def initialize(x, y, w, h)
      @remove = false
      @xoff = @yoff = @zoff = 0
      @x, @y, @w, @h = x, y, w, h
    end
    def update
    end
    def draw
    end
    def remove?
      return @remove
    end
  end
  
  # scrollable
  class Container < Element
    attr_reader :ch
    # ch = content element height
    def initialize(x, y, w, h, ch)
      super(x, y, w, h)
      @bg = EH.sprite("gui/container_background")
      @scrollbar = Scrollbar.new(x+w-24, y, 24, h)
      @ch = ch
      @items = []
      @item = nil
      @changed = false
    end
    
    def add(element)
      element.x = @x
      element.y = @y + @yoff + ((@items.size+1)*@ch)
      @items.push(element)
    end
    
    def hovered
      i = 0
      @items.each { |it|
        if it.hovered?
          return i
        end
        i += 1
      }
      return -1
    end
    
    def update
      # TODO scrollbar probably doesnt work
      @scrollbar.update
      @scrollbar.xoff, @scrollbar.yoff, @scrollbar.zoff = @xoff, @yoff, @zoff
      offset = @scrollbar.offset * -@ch
      @items.each { |item|
        item.xoff, item.zoff = @xoff, @zoff
        item.yoff = @yoff# + (offset/@ch) - @ch
        if item.y + item.yoff + item.h < @scrollbar.y + @scrollbar.yoff
          next
        end
        item.update
      }
    end
    
    def draw
      @scrollbar.draw
      @bg.draw(@x+@xoff, @y+@yoff, EH::GUI_Z, (@w-24)/@bg.width.to_f, @h/@bg.height.to_f)
      @items.each { |item|
        if item.y + item.yoff + item.h < @scrollbar.y + @scrollbar.yoff
          next
        end
        item.draw
      }
    end
    
    def selected
      return @item
    end
    
    def changed?
      if @changed
        @changed = false
        return true
      else
        return false
      end
    end
    
    private
    
    def clicked(item)
      @changed = true
      @item = item
    end
    
  end
  
  class Scrollbar < Element
    include Gosu
    attr_accessor :sh
    attr_reader :h
    def initialize(x, y, w, h)
      super
      @bg = EH.sprite("gui/scrollbar_background")
      @scroller = EH.sprite("gui/scroller")
      @held = false
      @sy = @y
      @sh = 48
    end
    def offset
      return ((@sy-@y)/((@y)-(@y+@h-@sh)+1))*-100
    end
    def update
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
      @bg.draw(@x+@xoff, @y+@yoff, EH::GUI_Z + 14, @w/@bg.width, @h/@bg.height.to_f)
      @scroller.draw(@x+@xoff, @sy+@yoff, EH::GUI_Z + 15, 1, @sh/@scroller.height.to_f)
    end
  end
  
end

require_relative "button.rb"
require_relative "context_menu.rb"
