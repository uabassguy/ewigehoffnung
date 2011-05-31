
# Note: This must be run from the lib directory.

require "rubygems"
require_relative "../eh.rb"

module EH
  module Tools
    
    include Gosu
    include REXML
    
    class AbstractMap
      attr_accessor :lower, :upper, :right, :left
      attr_reader :name
      def initialize(name)
        @name = name
        @lower = @upper = @right = @left = nil
      end
    end
    
    class WorldmapEditor < Window
      def initialize
        super(1024, 768, false)
        self.caption = "Ewige Hoffnung Worldmap Editor"
        EH.window = self
        @font = EH.font(EH::DEFAULT_FONT, 20)
        @xoff = @yoff = 0
        @unpress = []
        @gui = {
          :list => EH::GUI::Container.new(0, 0, 192, 768, 24)
        }
        @maps = []
        start = Time.now.sec
        Dir.new("maps/").each { |file|
          next if file == "." or file == ".." or File.directory?(file)
          map = EH::Parse.map(file.sub(".tmx", ""), true)
          if !map.properties[:name] or map.properties[:name].empty?
            map.properties[:name] = file.sub(".tmx", "")
          end
          map = AbstractMap.new(map.properties[:name])
          @maps.push(map)
          @gui[:list].add(EH::GUI::Button.new(0, 0, 168, 24, map.name, lambda { clicked(map) }, true, :left))
        }
        puts("INFO: Loaded #{@maps.size} maps in #{Time.now.sec - start} seconds")
        @world = load_world
      end
      
      def update
        @gui.each_value { |el|
          el.update
        }
        if @current and pressed?(Gosu::MsLeft) and mouse_x > 192
          place_map(mouse_x - 192, mouse_y)
        end
        if pressed?(Gosu::MsRight) and mouse_x > 192
          remove_map(mouse_x - 192, mouse_y)
        end
        unpress
      end
      
      def load_world
        begin
          file = File.open("tools/world.map", "r")
          world = Marshal.load(file)
          file.close
          return world
        rescue
          return Array.new(@maps.size) { Array.new(@maps.size) }
        end
      end
      
      def save_world
        Marshal.dump(@world, File.open("tools/world.map", "w"))
        y = 0
        @world.size.times {
          x = 0
          @world[y].size.times {
            if @world[y][x]
              @world[y][x].left = @world[y][x - 1] if x > 0
              @world[y][x].right = @world[y][x + 1] if x < @world[y].size
              @world[y][x].upper = @world[y - 1][x] if y > 0
              @world[y][x].lower = @world[y + 1][x] if y < @world.size
            end
            x += 1
          }
          y += 1
        }
      end
      
      def place_map(mx, my)
        x = mx.to_i/32
        y = my.to_i/24
        if y >= @world.size or x >= @world.first.size
          return
        end
        @world[y][x] = @current
      end
      
      def remove_map(mx, my)
        x = mx.to_i/32
        y = my.to_i/24
        if y >= @world.size or x >= @world.first.size
          return
        end
        @world[y][x] = nil
      end
      
      def draw
        @gui.each_value { |el|
          el.draw
        }
        y = 0
        @world.size.times {
          x = 0
          @world.size.times {
            if @world[y][x]
              px = 192 + @xoff + (x * 32)
              py = @yoff + (y * 24)
              c = Gosu::Color::GRAY
              draw_quad(px, py, c, px+32, py, c, px+32, py+24, c, px, py+24, c) 
            end
            x += 1
          }
          y += 1
        }
        x = (mouse_x.to_i - 192) / 32
        y = mouse_y.to_i / 24
        if @world[y] and @world[y][x]
          c = Gosu::Color::WHITE
          @font.draw(@world[y][x].name, mouse_x + 12, mouse_y + 12, 200, 1, 1, Gosu::Color::BLACK)
          w = @font.text_width(@world[y][x].name) + 8
          x = mouse_x + 8
          y = mouse_y + 8
          draw_quad(x, y, c, x+w, y, c, x+w, y+24, c, x, y+24, c, 100)
        end
      end
      
      def clicked(map)
        @current = map
      end
      
      def pressed?(key)
        p = button_down?(key)
        if p
          if @unpress.include?(key)
            p = false
          else
            @unpress.push(key)
          end
        end
        return p
      end
    
      def unpress
        @unpress.each { |key|
          if !button_down?(key)
            @unpress.delete(key)
          end
        }
      end
      
      def needs_cursor?
        return true
      end
      
    end
    
  end
end
  
begin
  editor = EH::Tools::WorldmapEditor.new
  editor.show
ensure
  editor.save_world
end
