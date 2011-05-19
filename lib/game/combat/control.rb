
module EH::Game::Combat
  
  # Used for scripted battles (dialogues and stuff)
  class Control
    def initialize(battle)
      @battle = nil
    end
    def battle=(b)
      @battle = b
    end
    def update
    end
    def draw
    end
  end
  
end