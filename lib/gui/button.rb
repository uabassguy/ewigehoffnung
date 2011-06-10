
module EH::GUI
  # Button to be used in menus.
  # Executes the given lambda when clicked
  class Button < Element
    attr_accessor :background, :proc
    @@sound = EH::Sample.new("click1")
    @@error = EH::Sample.new("error1")
    def initialize(x, y, w, h, text, proc, bg=true, align=:center, text_height=h)
      super(x, y, w, h)
      if bg
        @bg = EH.sprite("gui/button_background")
      end
      @hi = EH.sprite("gui/button_highlight", true)
      @font = EH.font(EH::DEFAULT_FONT, text_height)
      @text = text
      @proc = proc
      @selected = false
      @background = bg
      @align = align
      @enabled = true
    end
    def toggle
      @enabled = !@enabled
    end
    def disable
      @enabled = false
    end
    def enable
      @enabled = true
    end
    def update
      @selected = EH.inside?(EH.window.mouse_x, EH.window.mouse_y, @x+@xoff, @y+@yoff, @x+@w+@xoff, @y+@h+@yoff)
      if @selected and EH.window.pressed?(Gosu::MsLeft)
        if @enabled
          @@sound.play(0.25)
          @proc.call
        else
          @@error.play
        end
      end
    end
    def draw
      case @align
      when :center
        @font.draw(@text, @x + @xoff + (@w/2) - (@font.text_width(@text)/2), @y + @yoff + (@h/9), EH::GUI_Z + 10 + @zoff, 1, 1, Gosu::Color::BLACK)
      when :left
        @font.draw(@text, @x + @xoff + 4, @y + @yoff + (@h/9), EH::GUI_Z + 10 + @zoff, 1, 1, Gosu::Color::BLACK)
      when :right
        @font.draw(@text, @x + @xoff + (@w-@font.text_width(@text)), @y + @yoff + (@h/9), EH::GUI_Z + 10 + @zoff, 1, 1, Gosu::Color::BLACK)
      end
      if @background
        color = Gosu::Color.new(255, 255, 255, 255)
        if !@enabled
          color.saturation = 125
        end
        @bg.draw(@x + @xoff, @y + @yoff, EH::GUI_Z + 9 + @zoff, @w/@bg.width.to_f, @h/@bg.height.to_f, color)
      end
      if @selected and @enabled
        @hi.draw(@x + @xoff, @y + @yoff, EH::GUI_Z + 11 + @zoff, @w/@hi.width.to_f, @h/@hi.height.to_f, 0xff999999, :additive)
      end
    end
  end
  
  # Same as Button, but draws an image instead of text
  class ImageButton < Button
    attr_reader :bg
    def initialize(x, y, file, proc, w=-1, h=-1)
      @bg = EH.sprite(file.to_s)
      if w < 0
        @w = w = @bg.width
      end
      if h < 0
        @h = h = @bg.height
      end
      super(x, y, w, h, "", proc, false)
    end
    def draw
      color = Gosu::Color.new(255, 255, 255, 255)
      if !@enabled
        color.saturation = 125
      end
      @bg.draw(@x+@xoff, @y+@yoff, EH::GUI_Z + 10 + @zoff, @w/@bg.width.to_f, @h/@bg.height.to_f, color)
      if @selected and @enabled
        @hi.draw(@x+@xoff, @y+@yoff, EH::GUI_Z + 11 + @zoff, @w/@hi.width.to_f, @h/@hi.height.to_f, 0xff999999, :additive)
      end
    end
  end
end
