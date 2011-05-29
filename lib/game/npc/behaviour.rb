
require_relative "task.rb"
require_relative "parser.rb"

module EH::Game::NPC
  
  class Behaviour
    
    attr_reader :init, :trigger, :motion, :update
  
    def initialize(npc, init=[], trigger=[], motion=[], update=[])
      @self = npc
      @init = init
      @trigger = trigger
      @motion = motion
      @update = update
    end
    
    def on_init
      exec_tasks(@init)
      if !@motion.empty?
        @curr_motion = @motion.last
        on_endmotion
      end
    end
  
    def on_trigger(other)
      @trigger = exec_tasks(@trigger, other)
    end
  
    def on_update
      @update = exec_tasks(@update)
      on_endmotion if !@motion.empty? and @self.goal.state == :finished
    end
    
    def on_endmotion
      i = @motion.index(@curr_motion) + 1
      if i >= @motion.size
        i = 0
      end
      @curr_motion = @motion[i]
      exec_task(@curr_motion)
    end
    
    def exec_tasks(task, other=nil)
      ap task
      task.execute(self, other)
    end
    
    def exec_task(task, other=nil)
      if task.class == MotionTask
        task.execute(@self, other)
        return task
      end
      task.execute(@self, other) if !task.finished?
      if task.finished?
        if task.remove?
          task = nil
        end
      end
      return task
    end
  
  end

end