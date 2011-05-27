
require_relative "game/map/tile.rb"

module EH
  class Tileset
    @@tilesets = {}
    attr_reader :first, :name, :tiles, :props, :filename
    def initialize(fgid, name, filename, props)
      @first = fgid
      @name = name
      if !@@tilesets[filename]
        @@tilesets[filename] = Gosu::Image.load_tiles(EH.window, filename, 32, 32, true)
      end
      @tiles = @@tilesets[filename].dup
      @props = props
      @props.default = {}
      @filename = filename
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
    def tile(gid, x, y, z)
      if gid < 0
        return nil
      end
      if @filled.empty?
        create_tiles
      end
      tile = @filled[gid].dup
      tile.x, tile.y = x, y
      tile.z = z
      return tile
    end
  end
end
