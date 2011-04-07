
# Superclass for game states

require "cursor.rb"
require "particles.rb"

module EH::States
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
    end
    def draw_cursor
      @cursor.draw
    end
    def finish
    end
  end
  
  require "game/map/map_loader.rb"
  require "game/party.rb"
  class GameState < State
    attr_reader :map, :party
    def initialize(window)
      super(window)
      EH.window.state = self
      EH::Game.characters = EH::Parse.characters
      EH::Game.items = EH::Parse.items
      EH::Game.skills = EH::Parse.skills
      EH::Game.spells = EH::Parse.spells
      EH::Trans.parse_items
      EH::Trans.parse_skills
      EH::Trans.parse_dialogues
      @party = EH::Game::Party.new
      @map = EH::Game::MapLoader.new
      @map.load("test")
      # TODO move @objects to @map
      @setup = false
    end
    def update
      if @window.pressed?(Gosu::KbEscape)
        @window.save
        @window.advance(IngameMenu.new(EH.window, @party))
        return
      end
      @party.update
      @map.update
      update_cursor
      @window.unpress
      @setup = true
    end
    def draw
      @map.draw
      draw_cursor
    end
    def find_object(x, y)
      #puts("looking for object at #{x/32}|#{y/32} (#{x}|#{y}), player = #{@objects[0].x/32}|#{@objects[0].y/32} (#{@objects[0].x}|#{@objects[0].y})")
      @map.objects.each { |obj|
        if obj.x/32 == x/32 and obj.y/32 == y/32
          return obj
        end
      }
      return nil
    end
  end
end
