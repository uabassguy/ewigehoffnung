
module EH::Game
  
  def self.enemies
    return @enemies
  end
  
  def self.enemies=(ary)
    @enemies = ary
  end
  
  def self.find_enemy(name)
    @enemies.each { |enemy|
      if enemy.name == name
        return enemy
      end
    }
    return nil
  end
  
  def self.weapons
    return @weapons
  end
  
  def self.weapons=(hash)
    @weapons = hash
  end
  
  def self.find_weapon(name)
    @weapons.each { |w|
      if w.name == name
        return w
      end
    }
  end
  
  module Combat
    
    # For enemies
    class Behaviour
      def initialize(ary)
      end
    end
    
    # Used for scripted battles (dialogues and stuff)
    class Control
      def initialize(sym)
        @battle = nil
      end
      def battle=(b)
        @battle = b
      end
      def update
      end
      def draw
      end
    end
    
    class Background
      def initialize(file)
      end
      def update
      end
      def draw
      end
    end
    
    class Weapon
      attr_reader :name, :type, :effects, :icon
      def initialize(name, type, effects, icon)
        @name, @type, @effects, @icon = name, type, effects, EH.sprite("icons/#{icon}")
      end
    end
    
    # Superclass for enemies and actors
    class BattleObject
      attr_reader :graphic
      def initialize(graphic)
        @graphic = EH.sprite("combat/#{graphic}")
      end
      def update
      end
      def draw
      end
    end
    
    class Enemy < BattleObject
      attr_reader :name, :strength, :type, :weapons, :behaviour
      def initialize(name, strength, graphic, type, weapons, bhv)
        super(graphic)
        @name, @strength, @type, @weapons = name, strength, type, weapons
        @behaviour = bhv
      end
    end
    
    # Party member
    class Actor < BattleObject
      attr_reader :character
      def initialize(char)
        super(char.charset)
        @character = char
      end
    end
    
    class Party
      def initialize(party)
        @members = []
        create_actors(party)
      end
      private
      def create_actors(ary)
        ary.each { |char|
          @members.push(::Actor.new(char))
        }
      end
    end
    
    class Battle
      attr_reader :enemies, :background
      
      def initialize(party, enemies, bg, control=nil)
        @background = ::Background.new(bg)
        @enemies = enemies
        @party = ::Party.new(party)
        @control = control
        if @control
          @control.battle = self
        end
      end
      
      def update
        @background.update
        @control.update
      end
      
      def draw
        @background.draw
        @control.draw
      end
      
    end
    
  end
end
