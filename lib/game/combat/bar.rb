
module EH::Game::Combat

  class Bar
    attr_reader :value, :max
    attr_accessor :visible, :x, :y, :z
    def initialize(x, y, z, w, h, scheme, max, background)
      schemes = [:health, :endurance, :timer]
      @background = background
      @x, @y, @z = x, y, z
      @w, @h = w, h
      @scheme = scheme
      @value = @max = max
      @speed = @sub = @add = 0
      @visible = true
      @fade = 0
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
      if @fade > 0
        @fade -= @speed
      elsif @fade < 0
        @visible = false
        @fade = 0
      end
    end
    
    def fade(speed=10)
      @speed = speed
      @fade = 255
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
        when :timer
          if @value >= (@max / 4) * 3
            cl = cr = Gosu::Color::RED
          elsif @value >= @max / 2
            cl = cr = 0xFFFFB400
          elsif @value >= @max / 4
            cl = cr = Gosu::Color::YELLOW
          else
            cl = cr = Gosu::Color::GREEN
          end
        else
          cl = cr = Gosu::Color::WHITE
        end
      end
      if @fade > 0
        cl.alpha = @fade
        cr.alpha = @fade
      end
      if @value > 0
        w = @value / (@max / @w.to_f)
        EH.window.draw_quad(@x, @y, cl, @x+w, @y, cr, @x+w, @y+@h, cr, @x, @y+@h, cl, @z)
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