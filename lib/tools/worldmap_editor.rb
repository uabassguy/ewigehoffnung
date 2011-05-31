
# Note: This must be run from the lib directory.

require "rubygems"
require_relative "../eh.rb"

module EH
  module Tools
    
    include Gosu
    
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
          @maps.push(EH::Parse.map(file.sub(".tmx", ""), false))
          if !@maps.last.properties[:name] or @maps.last.properties[:name].empty?
            @maps.last.properties[:name] = file.sub(".tmx", "")
          end
          map = @maps.last
          @gui[:list].add(EH::GUI::Button.new(0, 0, 168, 24, @maps.last.properties[:name], lambda { clicked(map) }, true, :left))
        }
        puts("INFO: Loaded #{@maps.size} maps in #{Time.now.sec - start} seconds")
        @world = Array.new(@maps.size) { Array.new(@maps.size) }
      end
      
      def update
        @gui.each_value { |el|
          el.update
        }
        if @current and pressed?(Gosu::MsLeft) and mouse_x > 192
          place_map(mouse_x-192, mouse_y)
        end
        unpress
      end
      
      def place_map(mx, my)
        x = mx.to_i/32
        y = my.to_i/24
        if y >= @world.size or x >= @world.first.size
          return
        end
        @world[y][x] = @current
        @current = nil
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
          @font.draw(@world[y][x].properties[:name], mouse_x + 12, mouse_y + 12, 200, 1, 1, Gosu::Color::BLACK)
          w = @font.text_width(@world[y][x].properties[:name]) + 8
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

editor = EH::Tools::WorldmapEditor.new
editor.show