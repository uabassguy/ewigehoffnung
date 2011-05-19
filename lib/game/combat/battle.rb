
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
      def initialize(hash)
        @actions = {}
        hash.each { |k, v|
          i = 0
          v.each { |action|
            if !@actions[k]
              @actions.store(k, {})
            end
            @actions[k].store(i, action)
            i += 1
          }
        }
      end
      
      def execute(sym)
        ary = @actions[sym].values.flatten(1)
        ary.each { |str|
          params = str.split(" ")
          self.send(params.shift, params)
        }
      end
      
      private
      
      def vanish(*args)
        puts("STUB: Behaviour.vanish")
      end
      
      def drop(items)
        items.each { |item|
          puts("STUB: Behaviour.drop(#{item})")
        }
      end
      
      def attack(target)
        target = target.first
        puts("STUB: Behaviour.attack(#{target})")
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
      def initialize(file, color=nil)
        @sprite = EH.sprite("backgrounds/#{file}")
        if !color
          @color = Gosu::Color::WHITE
        else
          @color = color
        end
      end
      def update
      end
      def draw
        @sprite.draw(0, 0, 0, 1024/@sprite.width.to_f, 768/@sprite.height.to_f, @color)
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
      def initialize(graphic, x, y, z=EH::MAPOBJECT_Z, color=Gosu::Color::WHITE)
        @frame = 0
        @x, @y, @z = x, y, z
        @color = color
        if File.exists?("graphics/combat/#{graphic}.png")
          @graphics = Gosu::Image.load_tiles(EH.window, "graphics/combat/#{graphic}.png", -4, -4, false)
          @frame = 4
        else
          @graphics = [EH.sprite("missing")]
        end
      end
      def update
      end
      def draw
        @graphics[@frame].draw(@x, @y, @z, 1, 1, @color)
      end
    end
    
    class Enemy
      attr_reader :name, :strength, :type, :weapons, :behaviour, :graphic
      def initialize(name, strength, graphic, type, weapons, bhv)
        @graphic = graphic
        @name, @strength, @type, @weapons = name, strength, type, weapons
        @behaviour = bhv
      end
    end
    
    class BattleEnemy < BattleObject
      attr_reader :name, :strength, :type, :weapons, :behaviour
      def initialize(enemy, x, y, z)
        super(enemy.graphic, x, y, z)
      end
    end
    
    # Party member
    class Actor < BattleObject
      attr_reader :character
      def initialize(char, x, y, z)
        super(char.charset, x, y, z)
        @character = char
        @health = Bar.new(x - 8, y - 12, 100, 48, 6, :health, 100, false)
      end
      def update
        super
        @health.update
      end
      def draw
        super
        @health.draw
      end
    end
    
    class Party
      attr_reader :members
      def initialize(party)
        @members = []
        create_actors(party)
      end
      private
      def create_actors(party)
        x = y = 0
        party.members.each { |char|
          # TODO this is crap
          @members.push(Actor.new(char, 640+rand(48)+(x*128), 128+(y*96)+rand(48), 50))
          y += 1
          if y >= 4
            y = 0
            x += 1
          end
        }
      end
    end
    
    
    class Battle
      attr_reader :enemies, :background
      
      def initialize(party, enemies, bg, control=nil)
        @background = Background.new(bg)
        @enemies = enemies
        @party = Party.new(party)
        @control = control
        if @control
          @control.battle = self
        end
      end
      
      def update
        @background.update
        @control.update
        @enemies.each { |enemy|
          enemy.update
        }
        @party.members.each { |actor|
          actor.update
        }
      end
      
      def draw
        @background.draw
        @control.draw
        @enemies.each { |enemy|
          enemy.draw
        }
        @party.members.each { |actor|
          actor.draw
        }
      end
      
    end
    
  end
end

require "game/combat/bar.rb"
