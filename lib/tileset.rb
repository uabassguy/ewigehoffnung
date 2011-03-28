
require "game/tile.rb"

module EH
  class Tileset
    attr_reader :first, :name, :tiles
    def initialize(fgid, name, filename, props)
      @first = fgid
      @name = name
      @tiles = Gosu::Image.load_tiles(EH.window, filename, 32, 32, true)
      @props = props
      @props.default = {}
      @filled = []
    end
    def create_tiles
      @filled = []
      i = 0
      @tiles.each { |tile|
        @filled.push(EH::Game::Tile.new(tile, 0, 0, 0, @props[i]))
        i += 1
      }
      return @filled
    end
    def tile(gid, x, y)
      if gid < 0
        return nil
      end
      if @filled.empty?
        create_tiles
      end
      tile = @filled[gid].dup
      tile.x, tile.y = x, y
      return tile
    end
  end
end
