
module EH::GUI
  # Displays text in the given font and alignment
  class Textfield < Element
    
    def initialize(x, y, w, h, text="", size=20, align=:left)
      super(x, y, w, h)
      @bg = EH.sprite("gui/container_background")
      @font = EH.font(EH::DEFAULT_FONT, size)
      @text = []
      lines = text.split("\n")
      lines.each { |line|
        ary = line.split(" ")
        str = ""
        ary.each { |word|
          if @font.text_width(str + word) < @w - 18
            str += "#{word} "
          else
            str.rstrip!
            @text.push(str)
            str = "#{word} "
          end
          if word == ary.last
            str.rstrip!
            @text.push(str)
          end
        }
      }
      @align = align
    end
    
    def draw
      @bg.draw(@x+@xoff, @y+@yoff, EH::GUI_Z, (@w)/@bg.width.to_f, @h/@bg.height.to_f)
      y = 0
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
