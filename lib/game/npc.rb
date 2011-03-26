
require "game/map_object.rb"
require "game/goal.rb"

module EH::Game
  class NPC < MapObject
    def initialize(state, x, y, char, proc)
      super(state, char)
      @x, @y, @proc = x, y, proc
      @goal = CompositeGoal.new(:abort)
      @speed = 2
    end
    def setup
      #find_path_to(19, 14)
    end
    def find_path_to(x, y)
      puts("\nfrom #{@x/32}|#{@y/32} to #{x}|#{y}")
      curr = EH.window.state.map.astar(AStar::Node.new(@x/32, @y/32), AStar::Node.new(x, y))
      @goal.reset
      while curr and curr.parent
        @goal.push(MotionGoal.new((curr.x - curr.parent.x) * 32, (curr.y - curr.parent.y) * 32, x, y))
        curr = curr.parent
      end
      @goal.reverse!
    end
    def update(state)
      moved = update_move(state.map)
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
      if @goal.state == :finished
        @goal.reset
      end
    end
  end
end
