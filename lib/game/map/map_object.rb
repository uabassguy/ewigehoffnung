
module EH::Game
  class MapObject
    attr_reader :x, :y, :z, :name, :dy, :dx, :properties, :tx, :ty
    attr_accessor :through, :follow
    def initialize(x, y, props)
      file = props[:file]
      @properties = props
      @follow = false
      # TODO check for file first
      @graphics = Gosu::Image.load_tiles(EH.window, "graphics/chars/#{file}.png", -4, -4, false)
      @index = 0
      @x, @y = x, y
      @tx, @ty = x/32, y/32 # tile based position, used for collision
      @z = EH::MAPOBJECT_Z
      @z += props[:z] if props[:z]
      @speed = 0
      @speed += props[:speed] if props[:speed]
      @dx = @dy = 0 # distance to move, should be multiple of @speed
      @dead = false
      @steps = 0
      @trigger = nil
      @name = "mapobject-#{file.downcase}-#{rand(1000)}"
      @through = false
      @setup = true
      @stepped = false
    end
    
    def do_setup?
      return @setup
    end
    
    def setup
      if !@setup
        return false
      end
      if @setup
        @setup = false
      end
      return true
    end
    
    def update
      update_move(EH.window.state.map.current)
    end
    
    def update_move(map)
      moved = false
      if @dx > 0
        if @stepped or @through or map.passable?((@tx*32)+@dx, @ty*32)
          @x += @speed
          @dx -= @speed
          @tx += 1 if !@stepped
          @stepped = true
          moved = true
        else
          @dx = 0
        end
        @index = 8
      elsif @dx < 0
        if @stepped or @through or map.passable?((@tx*32)+@dx, @ty*32)
          @x -= @speed
          @dx += @speed
          @tx -= 1 if !@stepped
          @stepped = true
          moved = true
        else
          @dx = 0
        end
        @index = 4
      end
      if @dy > 0
        if @stepped or @through or map.passable?(@tx*32, (@ty*32)+@dy)
          @y += @speed
          @dy -= @speed
          @ty += 1 if !@stepped
          @stepped = true
          moved = true
        else
          @dy = 0
        end
        @index = 0
      elsif @dy < 0
        if @stepped or @through or map.passable?(@tx*32, (@ty*32)+@dy)
          @y -= @speed
          @dy += @speed
          @ty -= 1 if !@stepped
          @stepped = true
          moved = true
        else
          @dy = 0
        end
        @index = 12
      end
      if @dx == 0 and @dy == 0 and moved
        @steps += 1
        @stepped = false
      end
      if moved
        d = @dx
        if d == 0
          d = @dy
        end
        if d < 0
          d *= -1
        end
        if EH.between?(d, 8, 25)
          if @steps.even?
            @index += 1
          else
            @index += 3
          end
        end
      end
      return moved
    end
    
    def update_trigger
      # look for something on current tile
      obj = EH.window.state.find_object(@tx*32, @ty*32)
      if !obj or obj == self
        # look for something in the direction we're looking
        x = y = 0
        case direction
        when 0
          y = 32
        when 1
          x = -32
        when 2
          x = 32
        else
          y = -32
        end
        obj = EH.window.state.find_object((@tx*32)+x, (@ty*32)+y)
      end
      if obj
        obj.trigger(self)
      end
    end
    
    def draw(xoff, yoff)
      @graphics[@index].draw(@x+xoff, @y-16+yoff, @z)
    end
    
    def dead?
      return @dead
    end
    
    def trigger(other)
      @trigger.call(other) if @trigger
      @behaviour.on_trigger(other) if @behaviour
    end
    
    def direction
      if EH.between?(@index, -1, 4)
        return 0 # down
      elsif EH.between?(@index, 3, 8)
        return 1 # left
      elsif EH.between?(@index, 7, 12)
        return 2 # right
      elsif EH.between?(@index, 11, 16)
        return 3 # up
      end
    end
    
  end
end

require_relative "../npc/npc.rb"
require_relative "../map/player.rb"
