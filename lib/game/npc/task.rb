
module EH::Game::NPC
  
  class Task
    # action: proc to execute
    # wait: stall later tasks until this one finished
    # remove_after: delete task when finished
    def initialize(parameters, wait, remove_after=false)
      @array = parameters
      @wait, @remove = wait, remove_after
      @finished = false
      @current = 0
    end
  
    def execute(npc, other=nil)
      if !@array.empty? and !@finished
        send(@array[@current].first, @array[@current], npc, other)
      end
    end
    
    def empty?
      return @array.empty?
    end
  
    def wait?
      return @wait
    end
  
    def finished?
      return @finished
    end
  
    def remove?
      return @remove
    end
    
    def reset
      @finished = false
    end
    
    def next_subtask(npc, other)
      stop = false
      @current += 1
      if @current >= @array.size
        @current = 0
        if @remove
          @finished = true
        end
        stop = true
      end
      if !@finished and !@wait and !stop
        execute(npc, other)
      end
    end
    
    private
    
    def particles(parms, npc, other)
      npc.children.push(EH::Game::MapParticle.new(parms[1].x, parms[1].y, parms[2]))
      npc.children.last.xoff = npc.children.last.yoff = 16
      if parms.include?(:follow)
        npc.children.last.follow = true
      end
      next_subtask(npc, other)
    end
    
    def path_to(parms, npc, other)
      if npc.goal.state != :progress
        next_subtask(npc, other)
        npc.find_path_to(parms[1].x, parms[1].y)
        npc.goal.start
      end
    end
    
    def msg(parms, npc, other)
      EH.window.state.map.message(parms[1])
      next_subtask(npc, other)
    end
  
  end
  
  class DummyTask < Task
    def initialize
      super([], false, false)
    end
  end
  
end
