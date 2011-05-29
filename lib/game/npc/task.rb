
module EH::Game::NPC
  
  class Task
    # action: proc to execute
    # wait: stall later tasks until this one finished
    # remove_after: delete task when finished
    def initialize(parameters, wait, remove_after=false)
      @array = parameters
      @wait, @remove = wait, remove_after
      @finished = false
    end
  
    def execute(npc, other=nil)
      puts("Task.execute")
      ap @array
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
  
  class DummyTask < Task
    def initialize
      super([], false, false)
    end
  end
  
end
