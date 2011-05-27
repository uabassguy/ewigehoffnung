
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
    attr_reader :endurance, :state, :agility
    attr_accessor :health
    # health is only used as a percentage for easier displaying, the real stuff is in @const
    def initialize(name, charset, age, weight, strength, gender, race, agi)
      @name, @age, @charset, @race, @gender = name, age, charset, race, gender
      @weight, @strength = weight, strength
      @health = @endurance = 100
      @agility = agi
      if @agility > 100
        @agility = 0
      elsif @agility < 0
        @agility = 0
      end
      @inventory = EH::Game::Inventory.new(20, @strength)
      @skills = EH::Game::Skills.new
      @const = EH::Game::Constitution.new
      @mind = EH::Game::Mind.new
      @equipment = EH::Game::Equipment.new
      @magic = EH::Game::Magic.new(self)
      @state = EH::Game::NORMAL
    end
    
    def update
    end
    
    def calc_status
      if @endurance <= 25
        @state = EH::Game::DEAD
      elsif @endurance <= 0
        @state = EH::Game::UNCONSCIOUS
      end
    end
    
    def weaken(amount)
      if @state = EH::Game::DEAD
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
    
  end
end
