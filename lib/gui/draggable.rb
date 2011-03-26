
module EH::GUI
  
  class Draggable < Element
    def initialize(x, y, w, h, type, sprite)
      super(x, y, w, h)
      @type = type
      @sprite = sprite
    end
    def update(window)
      super
    end
    def draw
      @sprite.img.draw(@x, @y, EH::GUI_Z + 20, @w/@sprite.width, @h/@sprite.height)
    end
  end
  
end
