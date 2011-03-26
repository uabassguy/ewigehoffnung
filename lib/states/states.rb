
# Superclass for game states

require "particles.rb"

module EH::States
  class State
    attr_reader :window, :x, :y
    def initialize(window)
      @window = EH.window = window
      @x = @y = 0
      @cursor = EH::Sprite.new(window, "cursors/normal")
    end
    def update
      update_cursor
    end
    def update_cursor
      @x, @y = @window.mouse_x, @window.mouse_y
    end
    def draw
    end
    def draw_cursor
      @cursor.draw(@x, @y, EH::CURSOR_Z)
    end
    def finish
    end
  end
  
  require "game/map.rb"
  require "game/party.rb"
  class GameState < State
    attr_reader :map, :party
    def initialize(window)
      super(window)
      @map = EH::Game::Map.new("test", self.window)
      EH::Game.characters = EH::Parse.characters
      EH::Game.items = EH::Parse.items
      EH::Game.skills = EH::Parse.skills
      EH::Trans.parse_items
      EH::Trans.parse_skills
      @party = EH::Game::Party.new
      @objects = [EH::Game::Player.new(self, 32, 0), EH::Game::NPC.new(self, 0, 0, "eyera", nil)]
      @setup = false
    end
    def update
      if @window.pressed?(Gosu::KbEscape)
        @window.save
        @window.advance(IngameMenu.new(EH.window, @party))
      end
      @party.update
      @objects.each { |obj|
        obj.setup if !@setup
        obj.update(self)
        if obj.dead?
          @objects.delete(obj)
        end
      }
      update_cursor
      @window.unpress
      @setup = true
    end
    def draw
      @map.draw
      @objects.each { |obj|
        obj.draw
      }
      draw_cursor
    end
    def find_object(x, y)
      #puts("looking for object at #{x/32}|#{y/32} (#{x}|#{y}), player = #{@objects[0].x/32}|#{@objects[0].y/32} (#{@objects[0].x}|#{@objects[0].y})")
      @objects.each { |obj|
        if obj.x/32 == x/32 and obj.y/32 == y/32
          return obj
        end
      }
      return nil
    end
  end
end
