
module EH::GUI
  
  class Image < Element
    attr_accessor :color
    def initialize(x, y, img)
      @img = EH::Sprite.new(EH.window, "gui/#{img}")
      w, h, = @img.width, @img.height
      super(x, y, w, h)
      @color = Gosu::Color.new(255, 255, 255, 255)
    end
    def draw
      @img.img.draw(@x, @y, EH::GUI_Z + 10, 1, 1, @color)
    end
  end
  
end
