
require "def/spells.rb"

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
  end
  
  class Spell
    attr_reader :name, :icon, :type, :cost
    def initialize(sym, icon, type, cost)
      @name, @type, @cost = sym, type, cost
      @icon = EH.sprite("icons/spells/#{icon}")
    end
    
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
