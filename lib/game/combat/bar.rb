
module EH::Game::Combat

  class Bar
    attr_reader :value, :max
    attr_accessor :visible
    def initialize(x, y, z, w, h, scheme, max, background)
      schemes = [:health, :endurance, :timer]
      @background = background
      @x, @y, @z = x, y, z
      @w, @h = w, h
      @scheme = scheme
      @value = @max = max
      @speed = @sub = @add = 0
      @visible = true
    end
      
    def update
      if !@visible
        return
      end
      if @sub > 0
        @value -= @speed
        @sub -= @speed
      else
        @sub = 0
      end
      if @add > 0
        @value += @speed
        @add -= @speed
      else
        @add = 0
      end
    end
      
    def draw
      if !@visible
        return
      end
      if @background
        cb = Gosu::Color::BLACK
        EH.window.draw_quad(@x, @y, cb, @x+@w, @y, cb, @x+@w, @y+@h, cb, @x, @y+@h, cb, @z)
        case @scheme
        when :health
          cl = Gosu::Color::RED
          cr = Gosu::Color::GREEN
        else
          cl = Gosu::Color::BLACK
          cr = Gosu::Color::WHITE
        end
      else
        # TODO fluent fade
        case @scheme
        when :health
          if @value >= (@max / 4) * 3
            cl = cr = Gosu::Color::GREEN
          elsif @value >= @max / 2
            cl = cr = Gosu::Color::YELLOW
          elsif @value >= @max / 4
            cl = cr = 0xFFFFB400
          else
            cl = cr = Gosu::Color::RED
          end
        else
          cl = cr = Gosu::Color::WHIE
        end
      end
      if @value > 0
        x = @value / (@max / @w.to_f)
        EH.window.draw_quad(@x, @y, cl, @x+x, @y, cr, @x+x, @y+@h, cr, @x, @y+@h, cl, @z)
      end
    end
      
    def subtract(amount, speed)
      @sub = amount
      @speed = speed
    end
      
    def add(amount, speed)
      @add = amount
      @speed = speed
    end
      
    def set(val)
      @value = val
    end
  end
    
end