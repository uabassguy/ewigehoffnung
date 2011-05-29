
require_relative "task.rb"
require_relative "../map/map_particle.rb"

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
      @self.goal.reset
      exec_task(@motion)
    end
  
    def on_trigger(other)
      exec_task(@trigger, other)
    end
  
    def on_update
      exec_task(@update)
      exec_task(@motion)
    end
    
    def exec_task(task, other=nil)
      task.execute(@self, other) if !task.finished?
      if task.finished?
        if task.remove?
          task = nil
        end
      end
    end
  
  end

end