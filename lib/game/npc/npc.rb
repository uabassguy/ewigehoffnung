
require "game/map_object.rb"
require "game/npc/goal.rb"

# TODO move goal logic to mapobject

module EH::Game
  class MapNPC < MapObject
    attr_accessor :behaviour
    attr_reader :goal
    # cant take lambda because of argument
    def initialize(x, y, props, proc=proc {})
      super(x, y, props)
      @x, @y = x, y
      @trigger = proc
      @behaviour = nil
      @goal = CompositeGoal.new(:retry)
      @speed = 2
      @name = "npc-#{props[:file].downcase}-#{rand(1000)}"
    end
    def setup
      super
      @behaviour.on_init if @behaviour
    end
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
    end
  end
end
