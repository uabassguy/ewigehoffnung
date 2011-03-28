
# TODO move to root?

module EH::Game
  class Tile
    attr_reader :properties
    attr_accessor :x, :y, :z
    def initialize(sprite, x, y, z, props=[])
      @sprite = sprite
      @x, @y, @z = x, y, z
      if props[:collide]
        @passable = !props[:collide].to_b
      else
        @passable = true
      end
      @properties = props
    end
    def draw
      @sprite.draw(@x, @y, @z)
    end
    def passable?
      return @passable
    end
  end
end
