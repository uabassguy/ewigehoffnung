
require "game/inventory.rb"
require "game/skills.rb"
require "game/constitution.rb"
require "game/mind.rb"
require "game/equipment.rb"

module EH::Game
  def self.characters
    return @characters
  end
  def self.characters=(ary)
    @characters = ary
  end
  
  class Character
    attr_reader :name, :age, :charset, :weight, :strength, :charset, :gender
    attr_reader :inventory, :skills, :const, :mind, :equipment, :race
    attr_accessor :health
    # health is only used as a percentage for easier displaying, the real stuff is in @const
    def initialize(name, charset, age, weight, strength, gender, race)
      @name, @age, @charset, @race, @gender = name, age, charset, race, gender
      @weight, @strength = weight, strength
      @health = 100
      @inventory = EH::Game::Inventory.new(20, @strength)
      @skills = EH::Game::Skills.new
      @const = EH::Game::Constitution.new
      @mind = EH::Game::Mind.new
      @equipment = EH::Game::Equipment.new
    end
    def update
    end
  end
end
