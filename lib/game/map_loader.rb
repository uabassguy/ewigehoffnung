
module EH::Game
  class MapLoader
    def initialize
      @map = nil
    end
    def load(file)
      @map = EH::Parse.map(file)
    end
    def draw
      @map.draw
    end
    def update
      @map.update
    end
    def current
      return @map
    end
  end
end
