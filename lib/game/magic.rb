
# Characters use this class to manage spells and casting

module EH::Game
  
  class Magic
    attr_reader :learned
    def initialize(char)
      @char = char
      @learned = []
    end
    
    def learn(spell)
      @learned.push(spell) if !@learned.include?(spell)
    end
    
    def forget(spell)
      @learned.delete(spell)
    end
    
    def cast(spell, caster, target=nil)
      if @learned.include?(spell) and @char.state == EH::Game::NORMAL
        spell.cast(caster, target)
      end
    end
    
    def cast_named(name, caster, target=nil)
      cast(EH::Game.find_spell(name), caster, target)
    end
    
  end
  
end
