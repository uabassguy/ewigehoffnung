
require_relative "../def/spells.rb"

module EH::Game
  
  def self.spells
    return @spells
  end
  
  def self.spells=(ary)
    @spells = ary
  end
  
  def self.find_spell(name)
    @spells.each { |spell|
      if spell.name == name
        return spell
      end
    }
    return nil
  end
  
  class Spell
    attr_reader :name, :icon, :type, :cost
    def cast(caster, target=nil)
      puts("#{caster} casts #{self.name} on #{target}")
      if EH::Game::Spells.respond_to?(self.name)
        EH::Game::Spells.send(self.name)
      else
        puts("ERROR: No ruby definition for spell #{self.name} found")
      end 
    end
  end
  
end
