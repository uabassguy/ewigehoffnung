
module EH::GUI
  
  class ItemInfo < Element
    include EH
    def initialize(x, y)
      super(x, y, 672, 160)
      @bg = EH::Sprite.new(EH.window, "gui/iteminfo_background")
      @img = EH::Sprite.new(EH.window, "items/none")
      @bigfont = EH.font(EH::DEFAULT_FONT, 32)
      @font = EH.font(EH::DEFAULT_FONT, 24)
      @item = nil
    end
    def item=(item)
      @item = item
      if @item
        @img = @item.img
      else
        @img = EH::Sprite.new(EH.window, "items/none")
      end
    end
    def draw
      super
      @bg.img.draw(@x, @y, EH::GUI_Z + 9, @w/@bg.width.to_f, @h/@bg.height.to_f)
      @img.img.draw(@x, @y, EH::GUI_Z + 10, @h/@img.width.to_f, @h/@img.height.to_f)
      if @item
        @bigfont.draw(Trans.item(@item.name), @x+@h+4, @y+4, EH::GUI_Z + 11, 1, 1, Gosu::Color::BLACK)
        @font.draw(Trans.item("#{@item.name}_desc"), @x+@h+4, @y+36, EH::GUI_Z + 11, 1, 1, Gosu::Color::BLACK)
      end
    end
  end
  
end
