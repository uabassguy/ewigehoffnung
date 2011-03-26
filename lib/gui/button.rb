
module EH::GUI
  # TODO try to autogenerate backgrounds/highlights for new sizes
  class Button < Element
    attr_accessor :background
    def initialize(x, y, w, h, text, proc, bg=true, align=:center)
      super(x, y, w, h)
      if bg
        @bg = EH::Sprite.new(EH.window, "gui/button_background")
      end
      @hi = EH::Sprite.new(EH.window, "gui/button_highlight")
      @font = Gosu::Font.new(EH.window, EH::DEFAULT_FONT, h)
      @text = text
      @proc = proc
      @selected = false
      @background = bg
      @align = align
      @enabled = true
      @sound = EH::Sample.new(EH.window, "click1")
      @error = EH::Sample.new(EH.window, "error1")
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
    def update(window)
      @selected = EH.inside?(window.state.x, window.state.y, @x+@xoff, @y+@yoff, @x+@w+@xoff, @y+@h+@yoff)
      if @selected && window.state.window.pressed?(Gosu::MsLeft)
        if @enabled
          @sound.play(0.25)
          @proc.call
        else
          @error.play
        end
      end
    end
    def draw
      case @align
      when :center
        @font.draw(@text, @x + @xoff + (@w/2) - (@font.text_width(@text)/2), @y + @yoff + (@h/9), EH::GUI_Z + 10, 1, 1, Gosu::Color::BLACK)
      when :left
        @font.draw(@text, @x + @xoff + 4, @y + @yoff + (@h/9), EH::GUI_Z + 10, 1, 1, Gosu::Color::BLACK)
      when :right
        @font.draw(@text, @x + @xoff + (@w-@font.text_width(@text)), @y + @yoff + (@h/9), EH::GUI_Z + 10, 1, 1, Gosu::Color::BLACK)
      end
      if @background
        color = Gosu::Color.new(255, 255, 255, 255)
        if !@enabled
          color.saturation = 125
        end
        @bg.img.draw(@x + @xoff, @y + @yoff, EH::GUI_Z + 9, @w/@bg.width.to_f, @h/@bg.height.to_f, color)
      end
      if @selected and @enabled
        @hi.img.draw(@x + @xoff, @y + @yoff, EH::GUI_Z + 11, @w/@hi.width.to_f, @h/@hi.height.to_f)
      end
    end
  end
  
  class ImageButton < Button
    def initialize(x, y, file, proc, w=-1, h=-1)
      @bg = EH::Sprite.new(EH.window, "gui/#{file}")
      @sound = EH::Sample.new(EH.window, "click1")
      if w < 0
        @w = w = @bg.width
      end
      if h < 0
        @h = h = @bg.height
      end
      super(x, y, w, h, "", proc, false)
    end
    def update(window)
      @selected = EH.inside?(window.state.x, window.state.y, @x+@xoff, @y+@yoff, @x+@w+@xoff, @y+@h+@yoff)
      if @selected && window.state.window.pressed?(Gosu::MsLeft)
        if @enabled
          @sound.play(0.25)
          @proc.call
        else
          @error.play
        end
      end
    end
    def draw
      color = Gosu::Color.new(255, 255, 255, 255)
      if !@enabled
        color.saturation = 125
      end
      @bg.img.draw(@x+@xoff, @y+@yoff, EH::GUI_Z + 10, @w/@bg.width.to_f, @h/@bg.height.to_f, color)
      if @selected and @enabled
        @hi.img.draw(@x+@xoff, @y+@yoff, EH::GUI_Z + 11, @w/@hi.width.to_f, @h/@hi.height.to_f)
      end
    end
  end
end
