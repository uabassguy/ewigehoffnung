
require "game/character.rb"

module EH::Game
  
  # TODO < Array
  class Party
    attr_accessor :location, :player_index
    def initialize
      @members = []
      @members += EH::Game.characters
      @player_index = 0
      @location = ""
      (EH::Game.items.size * 5).times { @members[0].inventory.add(EH::Game.items.sample) }
      @members[0].equipment.equip(EH::Game.items[1], :rarm, @members[0].inventory)
    end
    def add(char)
      @members.push(char)
    end
    def remove(char)
      @members.delete(char)
    end
    def members
      return @members
    end
    def update
      @members.each { |m|
        m.update
      }
    end
    def player
      return @members[@player_index]
    end
  end
  
  # Character states
  NORMAL = 0
  ASLEEP = 1
  DEAD = 2
  UNCONSCIOUS = 3
  
end
