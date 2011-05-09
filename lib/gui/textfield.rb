
module EH::GUI
  # Displays text in the given font and alignment
  class Textfield < Element
    def initialize(x, y, w, h, text="", size=20, align=:left)
      super(x, y, w, h)
      @bg = EH.sprite("gui/container_background")
      @font = EH.font(EH::DEFAULT_FONT, size)
      @text = text
      @align = align
    end
    def draw
      @bg.draw(@x+@xoff, @y+@yoff, EH::GUI_Z, (@w)/@bg.width.to_f, @h/@bg.height.to_f)
      case @align
      when :center
        @font.draw(@text, @x + @xoff + (@w/2) - (@font.text_width(@text)/2), @y + @yoff + (@font.height/9), EH::GUI_Z + 10, 1, 1, Gosu::Color::BLACK)
      when :left
        @font.draw(@text, @x + @xoff + 8, @y + @yoff + (@font.height/9), EH::GUI_Z + 10, 1, 1, Gosu::Color::BLACK)
      when :right
        @font.draw(@text, @x + @xoff + (@w-@font.text_width(@text)), @y + @yoff + (@font.height/9), EH::GUI_Z + 10, 1, 1, Gosu::Color::BLACK)
      end
    end
  end
end
