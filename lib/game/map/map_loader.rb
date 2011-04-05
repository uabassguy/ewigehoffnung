
# 0 1 2
# 3 4 5
# 6 7 8
# 
# 4 => current

module EH::Game
  class MapLoader
    attr_reader :objects, :misc
    
    def initialize
      @objects = []
      @maps = []
      @misc = []
    end
    
    def load(file)
      map = EH::Parse.map(file)
      @objects = map.objects
      @objects.push(EH::Game::Player.new(32, 32))
      @maps[4] = map
      if map.upper
        @maps[1] = EH::Parse.map(map.upper)
        @maps[1].yoff = -@maps[1].height*32
        if @maps[1].left
          @maps[0] = EH::Parse.map(@maps[1].left)
          @maps[0].xoff = -@maps[1].height*32
          @maps[0].yoff = -@maps[0].height*32
        end
        if @maps[1].right
          @maps[2] = EH::Parse.map(@maps[1].right)
          @maps[2].xoff = @maps[1].height*32
          @maps[2].yoff = -@maps[1].height*32
        end
      end
      if map.right
        @maps[5] = EH::Parse.map(map.right)
        @maps[5].xoff = @maps[4].width*32
        if @maps[5].upper
          @maps[2] = EH::Parse.map(@maps[5].upper)
          @maps[2].xoff = @maps[4].width*32
          @maps[2].yoff = -@maps[2].height*32
        end
        if @maps[5].lower
          @maps[8] = EH::Parse.map(@maps[5].lower)
          @maps[8].xoff = @maps[4].width*32
          @maps[8].yoff = @maps[4].height*32
        end
      end
      if map.left
        @maps[3] = EH::Parse.map(map.left)
        @maps[3].xoff = -@maps[3].width*32
      end
      if map.lower
        @maps[7] = EH::Parse.map(map.lower)
        @maps[7].yoff = @maps[7].height*32
        if @maps[7].left
          @maps[6] = EH::Parse.map(@maps[7].left)
          @maps[6].xoff = -@maps[7].height*32
          @maps[6].yoff = @maps[7].height*32
        end
        if @maps[7].right
          @maps[8] = EH::Parse.map(@maps[7].right)
          @maps[8].xoff = @maps[7].height*32
          @maps[8].yoff = @maps[7].height*32
        end
      end
    end
    
    def draw
      @maps.each { |map|
        map.draw if map
      }
      @objects.each { |obj|
        obj.draw
      }
      @misc.each { |m|
        m.draw
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
      @misc.each { |obj|
        obj.update
      }
    end
    
    def current
      return @maps[4]
    end
  end
end
