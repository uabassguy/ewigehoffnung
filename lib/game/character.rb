
require_relative "inventory.rb"
require_relative "skills.rb"
require_relative "constitution.rb"
require_relative "mind.rb"
require_relative "equipment.rb"
require_relative "magic.rb"

module EH::Game
  def self.characters
    return @characters
  end
  def self.characters=(ary)
    @characters = ary
  end
  
  class Character
    attr_reader :name, :age, :weight, :strength, :charset, :gender
    attr_reader :inventory, :skills, :const, :mind, :equipment, :race, :magic
    attr_reader :endurance, :state, :agility, :spells, :influences
    attr_accessor :health
    # health is only used as a percentage for easier displaying, the real stuff is in @const
    
    def setup
      @health = @endurance = 100
      @inventory = EH::Game::Inventory.new(20, @strength)
      @skills = EH::Game::Skills.new
      @const = EH::Game::Constitution.new
      @mind = EH::Game::Mind.new
      @equipment = EH::Game::Equipment.new
      @magic = EH::Game::Magic.new(self)
      @state = EH::Game::NORMAL
      @spells = {}
      EH::Game.spells.each { |spell|
        @spells.store(spell, 0)
      }
      @charset = @file
      @file = EH.sprite(@file)
      @influences = []
      setup_skills
    end
    
    def validate
      if @agility > 100
        @agility = 0
      elsif @agility < 0
        @agility = 0
      end
    end
    
    def update
      @influences.each { |inf|
        inf.update(self)
      }
    end
    
    def consume(item)
    end
    
    def calc_status
      if @endurance <= 25
        @state = EH::Game::UNCONSCIOUS
      elsif @endurance <= 0
        @state = EH::Game::DEAD
      end
    end
    
    def weaken(amount)
      if @state != EH::Game::DEAD
        @endurance -= amount
        calc_status
      end
    end
    
    def rest(amount)
      if @state != EH::Game::DEAD
        @endurance -= amount
      end
    end
    
    def wake
      if @state != EH::Game::DEAD
        @state = EH::Game::NORMAL
        calc_status
      end
    end
    
    private
    
    def setup_skills
      @skills.list[EH::Game.find_skill(:healing)] = @healing
      @skills.list[EH::Game.find_skill(:crafting)] = @crafting
      @skills.list[EH::Game.find_skill(:botany)] = @botany
      @skills.list[EH::Game.find_skill(:healing_magic)] = @healing_magic
      @skills.list[EH::Game.find_skill(:mind)] = @mind
      @skills.list[EH::Game.find_skill(:elemental)] = @elemental
      @skills.list[EH::Game.find_skill(:ranged)] = @ranged
      @skills.list[EH::Game.find_skill(:melee)] = @melee
    end
    
  end
end
