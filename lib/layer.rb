
module EH
  class Layer
    attr_reader :properties, :tileset
    attr_accessor :filled
    def initialize(w, h, props, tiles, tileset=nil)
      @properties = props
      @z = EH::MAP_Z
      @z += props[:z].to_i if props[:z]
      create_tilemap(w, h, tiles)
      if tileset
        fill_tilemap(tileset)
      end
    end
    
    def create_tilemap(w, h, tiles)
      @tiles = Array.new(h) { [] }
      @filled = @tiles.dup
      wi = hi = 0
      tiles.each { |int|
        @tiles[hi].push(int)
        wi += 1
        if wi >= w
          wi = 0
          hi += 1
        end
      }
    end
    def fill_tilemap(tileset)
      @tileset = tileset
      @filled = Array.new(@tiles.size) { [] }
      h = w = 0
      @tiles.each { |ary|
        ary.each { |gid|
          @filled[h][w] = tileset.tile(gid-1, w*32, h*32, @z)
          w += 1
        }
        w = 0
        h += 1
      }
      return @filled
    end
  end
  
  class CollisionLayer
    attr_reader :tiles
    def initialize(w, h, tiles)
      create_tilemap(w, h, tiles)
    end
    def create_tilemap(w, h, tiles)
      @tiles = Array.new(h) { [] }
      wi = hi = 0
      tiles.each { |int|
        @tiles[hi].push(int)
        wi += 1
        if wi >= w
          wi = 0
          hi += 1
        end
      }
    end
  end
  
end
