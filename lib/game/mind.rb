
module EH::Game
  class Thought
    attr_reader :text, :proc
    def initialize(text, proc)
      @text, @proc = text, proc
    end
  end
  
  class Mind
    def initialize
      @thoughts = []
    end
    def contrive(thought)
      @thoughts.push(thought)
    end
    def forget(thought)
      @thoughts.delete(thought)
    end
    def thoughts
      return @thoughts
    end
  end
end
