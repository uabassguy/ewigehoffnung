
module EH::Game
  
  def self.enemies
    return @enemies
  end
  
  def self.enemies=(ary)
    @enemies = ary
  end
  
  module Combat
    
    class Behaviour
      def initialize
      end
    end
    
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
    
    # Superclass for enemies and actors
    class BattleObject
      def initialize
      end
      def update
      end
      def draw
      end
    end
    
    class Enemy < BattleObject
      attr_reader :name, :behaviour
      def initialize(name, strength, graphic, type, weapons, bhv)
        @name, @strength, @type, @weapons = name, strength, type, weapons
        @graphic = EH.sprite(graphic)
        @behaviour = bhv
      end
    end
    
    # Party member
    class Actor < BattleObject
      attr_reader :character
      def initialize(char)
        super
        @character = char
      end
    end
    
    class Party
      def initialize(party)
        @members = []
        create_members(party)
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
