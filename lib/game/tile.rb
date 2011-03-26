
module EH::Game
  class Tile
    def initialize(window, passable, id, x, y, z)
      @graphic = EH::Sprite.new(window, "tiles/#{id}", true)
      @x, @y, @z = x, y, z
      @passable = passable
    end
    def draw
      @graphic.draw(@x, @y, @z)
    end
    def passable?
      return @passable
    end
  end
end
