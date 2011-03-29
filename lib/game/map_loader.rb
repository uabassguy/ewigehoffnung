
module EH::Game
  class MapLoader
    attr_reader :objects
    def initialize
      @map = nil
      @objects = []
    end
    def load(file)
      @map = EH::Parse.map(file)
      @objects = @map.objects
      @objects.push(EH::Game::Player.new(32, 32))
    end
    def draw
      @map.draw
      @objects.each { |obj|
        obj.draw
      }
    end
    def update
      @objects.each { |obj|
        obj.setup if obj.do_setup?
        obj.update
        if obj.dead?
          @objects.delete(obj)
        end
      }
    end
    def current
      return @map
    end
  end
end
