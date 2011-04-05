
module EH::Game::NPC
  
  class Task
    # action: proc to execute
    # wait: stall later tasks until this one finished
    # remove_after: delete task when finished
    def initialize(action, wait, remove_after=false)
      @action = action
      @wait, @remove = wait, remove_after
      @finished = false
    end
  
    def execute(npc, other=nil)
      @action.call(npc, other) if !@finished
      if !@wait
        @finished = true
      end
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
  
  end
  
  class MotionTask < Task
    def initialize(action, wait=true, remove=false)
      super
      @started = false
    end
    def start
      @started = true
    end
    def stop
      @started = false
    end
    def started?
      return @started
    end
  end
  
end
