
module EH::GUI
  # Displays text in the given font and alignment
  class Textfield < Element
    
    attr_accessor :max_width
    
    def initialize(x, y, w, h, txt="", size=20, align=:left, fixed=true, maxw=w)
      super(x, y, w, h)
      @bg = EH.sprite("gui/container_background")
      @font = EH.font(EH::DEFAULT_FONT, size)
      @align = align
      @fixed = fixed
      @max_width = maxw
      set_text(txt)
    end
    
    def text=(text)
      if !@fixed
        @w = @max_width
      end
      @text = EH.multiline(text, @w, @font)
      if !@fixed
        @w = 8 + @font.text_width(@text.sort_by { |line| line.length}.reverse!.first)
        @h = 8 + @text.size * (@font.height)
      end
    end
    
    alias :set_text :text=
    
    def draw
      @bg.draw(@x+@xoff, @y+@yoff, EH::GUI_Z + @zoff, (@w)/@bg.width.to_f, @h/@bg.height.to_f)
      y = 0
      if @text.size == 1
        y += 4
      end
      @text.each { |line|
        case @align
        when :center
          @font.draw(line, @x + @xoff + (@w/2) - (@font.text_width(line)/2), @y + @yoff + (@font.height/9) + y, EH::GUI_Z + 10 + @zoff, 1, 1, Gosu::Color::BLACK)
        when :left
          @font.draw(line, @x + @xoff + 4, @y + @yoff + (@font.height/9) + y, EH::GUI_Z + 10 + @zoff, 1, 1, Gosu::Color::BLACK)
        when :right
          @font.draw(line, @x + @xoff + (@w-@font.text_width(line)), @y + @yoff + (@font.height/9) + y, EH::GUI_Z + 10 + @zoff, 1, 1, Gosu::Color::BLACK)
        end
        y += @font.height
      }
    end
    
  end
end
