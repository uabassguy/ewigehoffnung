
module EH::Game
  
  class Bubble < EH::GUI::Textfield
    
    def initialize(text)
      super(0, 0, 0, 0, text, 20, :left, false, 256)
      @age = text.gsub("\n", "").size * EH.config[:text_speed]
    end
    
    def update
      if @age <= 0
        @remove = true
      else
        @age -= 1
      end
    end
    
    def draw(x, y)
      @x, @y = x-(@w/2)+16, y-40-@h
      super()
      c = Gosu::Color::GREEN
      EH.window.draw_triangle(@x+(@w/2)-4, @y+@h, c, @x+(@w/2)+4, @y+@h, c, @x+(@w/2), @y+@h+24, c, EH::MAPOBJECT_Z+100)
    end
    
  end
  
end
