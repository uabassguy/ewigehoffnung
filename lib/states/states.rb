
# Superclass for game states

require_relative "../cursor.rb"
require_relative "../particles.rb"

module EH::States
  # Skeleton for game states
  # 
  # Provides a cursor
  class State
    attr_reader :window, :x, :y
    def initialize(window)
      @window = EH.window = window
      @x = @y = 0
      @cursor = EH::Cursor.new
    end
    def update
      update_cursor
    end
    def update_cursor
      @x, @y = @window.mouse_x, @window.mouse_y
      @cursor.update(@x, @y)
    end
    def draw
      draw_cursor
    end
    def draw_cursor
      @cursor.draw
    end
    def finish
    end
  end
  
  require_relative "../game/map/map_loader.rb"
  require_relative "../game/party.rb"
  require_relative "../game/osd/magic.rb"
  # Runs the map and basic game logic
  class GameState < State
    
    attr_reader :map, :party, :osd
    
    def initialize(window)
      super(window)
      EH.window.state = self
      EH::Game.items = EH::Parse.items
      EH::Game.skills = EH::Parse.skills
      EH::Game.spells = EH::Parse.spells
      EH::Game.weapons = EH::Parse.weapons
      EH::Game.enemies = EH::Parse.enemies # needs the weapons
      EH::Game.characters = EH::Parse.characters
      EH::Game::Alchemy.recipies = EH::Parse.recipies
      EH::Trans.parse_items
      EH::Trans.parse_skills
      EH::Trans.parse_spells
      EH::Trans.parse_dialogues
      EH::Trans.parse_enemies
      @party = EH::Game::Party.new
      @map = EH::Game::MapLoader.new
      @map.load("test") # TODO fetch from init.def
      @setup = false
      @context = nil
      @osd = {}
    end
    
    def update
      if @window.pressed?(Gosu::KbEscape)
        @window.save
        @window.advance(IngameMenu.new(EH.window, @party))
        return
      end
      if @window.pressed?(Gosu::MsRight) and @context ? !EH.inside?(@window.mouse_x, @window.mouse_y, @context.x, @context.y, @context.x+@context.w, @context.y+@context.h) : true
        obj = find_object(@window.mouse_x.to_i - @map.xoff, @window.mouse_y.to_i - @map.yoff)
        @context = EH::GUI::ContextMenu.new(@window.mouse_x, @window.mouse_y, obj)
      end
      if @context
        @context.update
        # TODO fade context menu
        if (@window.pressed?(Gosu::MsLeft) and !EH.inside?(@window.mouse_x, @window.mouse_y, @context.x, @context.y, @context.x+@context.w, @context.y+@context.h)) or @context.remove?
          #@context.fade
          @context = nil
        end
        #if @context.faded?
        #end
      end
      @party.update
      @map.update
      @osd.each_value { |w|
        w.update
        if w.remove?
          @osd.delete(@osd.key(w))
        end
      }
      update_cursor
      @window.unpress
      @setup = true
      #battle([EH::Game.enemies.first], "white_ties_grass", EH::Game::Combat::Control.new(:test))
    end
    
    def draw
      @map.draw
      @osd.each_value { |w|
        w.draw
      }
      @context.draw if @context
      draw_cursor
    end
    
    # Looks for an objects on the current map at the given screen coordinates
    # 
    # Returns +nil+ if nothing was found
    def find_object(x, y)
      #puts("looking for object at #{x/32}|#{y/32} (#{x}|#{y})")
      @map.objects.each { |obj|
        if obj.x/32 == x/32 and obj.y/32 == y/32
          #puts("found #{obj.inspect}")
          return obj
        end
      }
      return nil
    end
    
    def player
      @map.objects.each { |obj|
        if obj.class == EH::Game::Player
          return obj
        end
      }
    end
    
    def battle(enemies, bg, ctrl)
      EH.window.save
      EH.window.advance(BattleState.new(@party, enemies, bg, ctrl))
    end
    
  end
  
  class BattleState < State
    def initialize(party, enemies, bg, ctrl)
      super(EH.window)
      @battle = EH::Game::Combat::Battle.new(party, enemies, bg, ctrl)
    end
    def update
      super
      @battle.update
    end
    def draw
      super
      @battle.draw
    end
  end
  
end
