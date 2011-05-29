
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
      ap self
    end
    
    def on_init
      exec_task(@init)
    end
  
    def on_trigger(other)
      exec_task(@trigger, other)
    end
  
    def on_update
      exec_task(@update)
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
    
    def exec_task(task, other=nil)
      if task.class == MotionTask
        task.execute(@self, other)
        return
      end
      task.execute(@self, other) if !task.finished?
      if task.finished?
        if task.remove?
          task = nil
        end
      end
    end
  
  end

end