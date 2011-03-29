
# FIXME policy = :recalc doesnt work

module EH::Game
  
  class Goal
    def initialize
      @state = :before
    end
    def setup
      @state = :progress
    end
    def state
      return @state
    end
    def restart
      @state = :before
    end
    def recalc
      restart
    end
  end
  
  class MotionGoal < Goal
    attr_reader :dx, :dy, :x, :y
    attr_accessor :state
    def initialize(dx, dy, x, y)
      super()
      @dx, @dy = dx, dy
      @x, @y = x, y
    end
    def recalc
      @state = :recalc
    end
  end
  
  class CompositeGoal < Array
    attr_reader :state
    def initialize(policy=:abort)
      super()
      @current = 0
      @policy = policy
      @state = :progress
    end
    def reset
      self.clear
      @current = 0
    end
    def current
      return self[@current]
    end
    def update
      if @state == :progress
        awesome_print(self) if !current
        case current.state
        when :before
          if current.class != MotionGoal
            current.setup
          end
        when :progress
          return
        when :failed
          handle_failed
        when :finished
          advance
        end
      end
    end
    def advance
      @current += 1
      if @current == self.size
        @state = :finished
        @current = 0
      end
    end
    private
    def handle_failed
      case @policy
      when :abort
        @state = :failed
      when :retry
        current.restart
      when :recalc
        current.recalc
      end
    end
  end
  
end
