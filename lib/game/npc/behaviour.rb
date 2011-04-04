
require "game/npc/task.rb"
require "game/npc/parser.rb"

module EH::Game::NPC
  
  class Behaviour
    
    attr_reader :init, :trigger, :motion, :update
  
    def initialize(npc, init=[], trigger=[], motion=[], update=[])
      @init = init
      @trigger = trigger
      @motion = motion
      @update = update
      @self = npc
    end
    
    def on_init
      exec_tasks(@init)
      awesome_print(@init)
    end
  
    def on_trigger(other)
      @trigger = exec_tasks(@trigger)
    end
  
    def on_update
      @update = exec_tasks(@update)
      @motion = exec_tasks(@motion)
      if !@motion.empty? and @motion.last.finished?
        @motion.each { |task|
          task.reset
        }
        puts("reset tasks")
        puts(@motion.inspect)
      end
    end
    
    def exec_tasks(ary, other=nil)
      ary.each { |task|
        task.execute(@self, other) if !task.finished?
        if task.finished?
          if task.remove?
            ary.delete(task)
          end
          puts("task executed & finished")
          next
        end
        if task.wait? and !task.finished?
          break
        end
      }
      return ary
    end
  
  end

end