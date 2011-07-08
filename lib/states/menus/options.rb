
module EH::States
    
  class OptionMenu < State
    include EH::GUI
    include EH
    def initialize(window)
      super(window)
      @background = EH.sprite("menu/ingame_background")
      @restart = false
      @w = EH::GUI::Window.new(0, 0, 1024, 768, Trans.menu(:options))
      @w.add(:details, Window.new(288, 56, 704, 128, Trans.menu(:options_details), false, "gui/options_details"))
      @w.add(:language, Button.new(32, 32, 224, 32, Trans.menu(:language), lambda {swap(:language)}, true, :left))
      @w.add(:volume, Button.new(32, 80, 224, 32, Trans.menu(:volume), lambda {swap(:volume)}, true, :left))
    end
    def swap(sym)
      detail = @w[:details]
      detail.empty
      case sym
      when :language
        detail.add(:en, Button.new(16, 16, 96, 24, Trans.menu(:lang_english), lambda {language(:en)}, true, :left))
        detail.add(:de, Button.new(16, 48, 96, 24, Trans.menu(:lang_german), lambda {language(:de)}, true, :left))
        detail[EH.config[:language].to_sym].disable
      when :volume
        detail.add(:slider, Slider.new(16, 16, 128, 32))
      end
    end
    def language(sym)
      EH.config[:language] = sym.to_s
      swap(:language)
      @restart = true
    end
    def update
      if @window.pressed?(Gosu::KbEscape) or @w.remove?
        if @restart
          EH.exit(0)
        else
          EH.window.advance(StartMenu.new(EH.window))
        end
      end
      @w.update
      if @restart and !@w[:details].include?(:warning)
        @w[:details].add(:warning, Textfield.new(384, 16, 320, 96, Trans.menu(:restart_warning)))
      end
      update_cursor
    end
    def draw
      @background.draw(0, 0, 0)
      @w.draw
      draw_cursor
    end
  end
  
end
