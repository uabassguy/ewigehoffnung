
# 0 1 2
# 3 4 5
# 6 7 8
# 
# 4 => current

require "game/map/fog.rb"

module EH::Game
  class MapLoader
    
    attr_reader :objects, :misc
    
    def initialize
      @objects = []
      @maps = []
      @misc = []
      @tonepic = EH::Sprite.new(EH.window, "pixel", true)
      @message = nil
      @font = EH.font(EH::DEFAULT_FONT, 24)
      @msgimg = EH::Sprite.new(EH.window, "gui/msg_background")
    end
    
    def current
      return @maps[4]
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
      if map.properties[:music]
        if map.properties[:music] == "nil"
          @song.stop if @song
        else
          @song = EH::Song.new(map.properties[:music])
          @song.play(true)
        end
      end
      if map.properties[:fog]
        if map.properties[:fog] == "nil"
          @fog = nil
        else
          @fog = EH::Game::Fog.new(map.properties[:fog], map.properties[:fogx].to_f, map.properties[:fogy].to_f, map.properties[:foga].to_i, map.properties[:fogr].to_i, map.properties[:fogg].to_i, map.properties[:fogb].to_i)
        end
      end
      if map.properties[:tonea] or map.properties[:toner] or map.properties[:toneg] or map.properties[:toneb]
        @tone = Gosu::Color.new(map.properties[:tonea].to_i, map.properties[:toner].to_i, map.properties[:toneg].to_i, map.properties[:toneb].to_i)
      else
        @tone = nil
      end
    end
    
    def update
      if !@message
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
      else
        if EH.window.pressed?(Gosu::KbSpace)
          @message = nil
        end
      end
      @fog.update if @fog
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
      @fog.draw if @fog
      @tonepic.img.draw(0, 0, 500000, 1024, 768, @tone) if @tone
      if @message
        @msgimg.img.draw(@mx, @my, EH::CURSOR_Z-10, @msgimg.img.width/@mw.to_f, @msgimg.img.height/@mh.to_f)
        # TODO multiline rendering (array)
        @font.draw(@message, @mx+8, @my+8, EH::CURSOR_Z-9, 1, 1, 0xff000000)
      end
    end
    
    def message(str, x=256, y=480, w=512, h=224)
      @message = str
      @mx, @my = x, y
      @mw, @mh = w, h
    end
    
  end
end
