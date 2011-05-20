
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
      @fade = 256
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
      if @fade > 0 and @fade <= 255
        @fade -= @speed
      elsif @fade <= 0
        @fade = 0
        @visible = false
      end
    end
    
    def fade(speed=15)
      @speed = speed
      @fade = 255
    end
      
    def draw
      if !@visible
        return
      end
      if @background
        cb = Gosu::Color.new(255, 0, 0, 0)
        EH.window.draw_quad(@x, @y, cb, @x+@w, @y, cb, @x+@w, @y+@h, cb, @x, @y+@h, cb, @z)
        case @scheme
        when :health
          cl = Gosu::Color.new(255, 255, 0, 0)
          cr = Gosu::Color.new(255, 0, 255, 0)
        else
          cl = Gosu::Color.new(255, 0, 0, 0)
          cr = Gosu::Color.new(255, 255, 255, 255)
        end
      else
        # TODO fluent fade
        case @scheme
        when :health
          if @value >= (@max / 4) * 3
            cl = cr = Gosu::Color.new(255, 0, 255, 0)
          elsif @value >= @max / 2
            cl = cr = Gosu::Color.new(255, 255, 255, 0)
          elsif @value >= @max / 4
            cl = cr = Gosu::Color.new(255, 255, 180, 0)
          else
            cl = cr = Gosu::Color.new(255, 255, 0, 0)
          end
        when :timer
          if @value >= (@max / 4) * 3
            cl = cr = Gosu::Color.new(255, 255, 0, 0)
          elsif @value >= @max / 2
            cl = cr = Gosu::Color.new(255, 255, 180, 0)
          elsif @value >= @max / 4
            cl = cr = Gosu::Color.new(255, 255, 255, 0)
          else
            cl = cr = Gosu::Color.new(255, 0, 255, 0)
          end
        else
          cl = cr = Gosu::Color.new(255, 255, 255, 255)
        end
      end
      if @fade <= 255
        f = @fade
        if f < 0
          f = 0
        end
        cl.alpha = f
        cr.alpha = f
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