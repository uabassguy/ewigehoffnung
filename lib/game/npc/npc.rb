
require_relative "goal.rb"
require_relative "bubble.rb"

# TODO move goal logic to mapobject

module EH::Game
  # Interactive map object
  class MapNPC < MapObject
    attr_accessor :behaviour
    attr_reader :goal, :gamename, :children
    def initialize(x, y, props)
      super(x, y, props)
      @x, @y = x, y
      @behaviour = nil
      @goal = CompositeGoal.new(:retry)
      @speed = 2
      @name = "npc-#{props[:file].downcase}-#{rand(1000)}"
      @gamename = props[:name] ? props[:name] : @name
      @children = []
      @bubble = nil
    end
    
    def setup
      super
      @behaviour.on_init if @behaviour
    end
    
    # Generates a path from the current position to the given screen coordinates by using A*
    def find_path_to(x, y)
      #puts("from #{@x/32}|#{@y/32} to #{x}|#{y}")
      curr = EH.window.state.map.current.astar(AStar::Node.new(@x/32, @y/32), AStar::Node.new(x, y))
      @goal.reset
      while curr and curr.parent
        @goal.push(MotionGoal.new((curr.x - curr.parent.x) * 32, (curr.y - curr.parent.y) * 32, x, y))
        curr = curr.parent
      end
      @goal.reverse!
      @goal.start
      return @goal
    end
    
    def update
      @children.each { |child|
        if child.follow
          child.x = @x + child.xoff
          child.y = @y + child.yoff
        end
        child.update
      }
      @behaviour.on_update if @behaviour
      moved = update_move(EH.window.state.map.current)
      @goal.update if @goal.size > 0
      if @goal.current.class == MotionGoal
        if @goal.current.state == :recalc
          @dx = @dy = 0
          find_path_to(@goal.last.x, @goal.last.y)
          @goal.update
        end
        if @dx == 0 and @dy == 0
          if @goal.current.state == :before
            @dx, @dy = @goal.current.dx, @goal.current.dy
            @goal.current.state = :progress
          elsif @goal.current.state == :progress
            if moved
              @goal.advance
            else
              @goal.current.state = :failed
            end
          end
        end
      end
      if @bubble
        @bubble.update
        @bubble = nil if @bubble.remove?
      end
    end
    
    def draw(x, y)
      super
      @bubble.draw(@x+x, @y+y) if @bubble
      @children.each { |child| child.draw(x, y) }
    end
    
    # Displays a speech bubble with the given text
    def talk(text)
      @bubble = Bubble.new(text)
    end
    
    def destroy_goal
      @goal.reset
    end
    
  end
end
