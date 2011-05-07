
module EH::GUI
  class Textfield < Element
    def initialize(x, y, w, h, text="")
      super(x, y, w, h)
      @bg = EH.sprite("gui/container_background")
    end
    def draw
      @bg.draw(@x+@xoff, @y+@yoff, EH::GUI_Z, (@w-24)/@bg.width.to_f, @h/@bg.height.to_f)
    end
  end
end
