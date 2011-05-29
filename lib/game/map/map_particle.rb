
module EH::Game
  
  class MapParticle
    attr_accessor :follow, :xoff, :yoff
    def initialize(x, y, effect)
      @emitter = EH::Particles.new(effect, x, y)
    end
    
    def x=(x)
      @emitter.x = x
    end
    
    def y=(y)
      @emitter.y = y
    end
    
    def update
      @emitter.update
    end
    
    def draw
      @emitter.draw
    end
  end
  
end
