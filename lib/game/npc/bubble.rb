
module EH::Game
  
  class Bubble < EH::GUI::Textfield
    
    def initialize(x, y, w, h, text)
      super(x, y, w, h, text, 20, :left, false, 256)
    end
    
    def draw(x, y)
      @x, @y = x-(@w/2)+16, y-40-@h
      super()
      c = Gosu::Color::GREEN
      EH.window.draw_triangle(@x+(@w/2)-4, @y+@h, c, @x+(@w/2)+4, @y+@h, c, @x+(@w/2), @y+@h+24, c, EH::MAPOBJECT_Z+100)
    end
    
  end
  
end
