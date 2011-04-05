
# TODO floats for position and speeds

module EH
  def self.particles
    return @particles
  end
  def self.particles=(hsh)
    @particles = hsh
  end
  
  class Particles
    def initialize(str, x=0, y=0)
      @emitter = EH.particles[str].dup
      @emitter.x, @emitter.y = x, y
    end
    def x=(x)
      @emitter.x = x
    end
    def y=(y)
      @emitter.y = y
    end
    def wind=(w)
      @emitter.wind = w
    end
    def gravity=(g)
      @emitter.gravity = g
    end
    def update
      @emitter.update
    end
    def draw
      @emitter.draw
    end
  end
  
  class Particle
    attr_accessor :wind, :gravity
    def initialize(x, y, file, lifetime, fade_in, fade_out, sx, sy, angle, color, mode)
      @img = EH::Sprite.new(EH.window, "particles/#{file}")
      @dead = false
      @age = 0
      @wind = @gravity = 0
      @x, @y, @lifetime, @fade_in, @fade_out, @sx, @sy, @angle, @color, @mode = x, y, lifetime, fade_in, fade_out, sx, sy, random_angle(angle), color, mode
    end
    def random_angle(bool)
      angle = 0
      if bool
        angle = rand(360)
      end
      return angle
    end
    def update
      @x += @sx + @wind
      @y += @sy + @gravity
      @age += 1
      if @x > 1024 or @x < -@img.width or @y > 768+@img.height or @y < -@img.height or @age >= @lifetime
        @dead = true
      end
    end
    def dead?
      return @dead
    end
    def draw
      color = @color
      if @age < @fade_in
        a = 125 + ((((@age - @fade_in) * 255) / @lifetime))
        a *= 2
      elsif @age >= @lifetime - @fade_out
        a = ((@lifetime - @age) * 255 / @age).to_i
      else
        a = 255
      end
      if a > 255
        a = 255
      elsif a < 0
        a = 0
      end
      color.alpha = a.to_i;
      @img.img.draw_rot(@x, @y, EH::PARTICLE_Z, @angle, 0.5, 0.5, 1, 1, color, @mode)
    end
  end
  
  class ParticleEmitter
    attr_accessor :x, :y, :xr, :yr
    def initialize(file, lifetime, fade_in, fade_out, color, delay, angle, mode, xr, yr, xo, yo)
      @lifetime, @fade_in, @fade_out, @color, @angle = lifetime, fade_in, fade_out, color, angle
      @xoff, @yoff = xo, yo
      @delay, @file, @mode = delay, file, mode
      @particles = []
      @next = 0
      @xr, @yr, = xr, yr
      @wind = @gravity = 0
    end
    def update
      @next -= 1
      if @next <= 0
        spawn_particle
        @next = @delay
      end
      @particles.each { |p|
        p.update
        if p.dead?
          @particles.delete(p)
        end
      }
    end
    def spawn_particle
      sx = @xr.to_a.sample
      sy = @yr.to_a.sample
      @particles.push(EH::Particle.new(@x+@xoff.to_a.sample, @y+@yoff.to_a.sample, @file, @lifetime, @fade_in, @fade_out, sx, sy, @angle, @color.dup, @mode))
      @particles.last.wind = @wind
      @particles.last.gravity = @gravity
    end
    def draw
      @particles.each { |p|
        p.draw
      }
    end
    def wind=(w)
      @wind = w
    end
    def gravity=(g)
      @gravity = g
    end
  end
end

EH.particles = EH::Parse.particles
