
# General system interface and common convenience functions

require "awesome_print"
require "gosu"

# Main entrance point of the engine
module EH
  # Source locations
  LIBRARY_PATH = File.dirname(__FILE__)
  # For storing saves and updates in case the source folder is write protected
  HOME_PATH = "#{ENV["HOME"]}/.ewigehoffnung/"
  if !File.directory?(HOME_PATH)
    Dir.mkdir("#{ENV["HOME"]}/.ewigehoffnung")
  end
  if !File.directory?("#{HOME_PATH}saves")
    Dir.mkdir("#{HOME_PATH}saves")
  end
  
  VERSION = 0.1
  RELEASE = false

  #--
  # Game
  MAP_Z = 1
  MAPOBJECT_Z = 50 
  CURSOR_Z = 1000000
  GUI_Z = 9999
  PARTICLE_Z = 5000
  FOG_Z = 6000
  
  DEFAULT_FONT = "arial"
  
  DEFAULT_CONFIG = "default.cfg"
  
  @window = nil
  # Returns the global Gosu::Window instance
  def self.window
    return @window
  end
  # Globally sets the Gosu::Window instance
  def self.window=(w)
    @window = w
  end
  
  def self.inside?(x, y, startx, starty, endx, endy)
    if x >= startx && x < endx && y >= starty && y < endy
      return true
    end
    return false
  end
  
  # a between b and c
  def self.between?(a, b, c)
    if a > b and a < c
      return true
    end
    return false
  end
    
  def self.multiline(text, width, font)
    ret = []
    lines = text.split("\n")
    lines.each { |line|
      ary = line.split(" ")
      str = ""
      ary.each { |word|
        if font.text_width(str + word) < width - 18
          str += "#{word} "
        else
          str.rstrip!
          if str != ""
            ret.push(str)
          end
          str = "#{word} "
        end
        if word == ary.last
          str.rstrip!
          ret.push(str)
        end
      }
    }
    return ret
  end
  
  @@fonts = {}
  
  # Returns a cached font instance
  def self.font(name, size)
    if @@fonts["#{name}-#{size}".to_sym]
      return @@fonts["#{name}-#{size}".to_sym]
    else
      @@fonts["#{name}-#{size}".to_sym] = Gosu::Font.new(EH.window, name, size)
    end
  end
  
  require_relative "config.rb"
  
  @config = Config.new
  @config.load
  def self.config
    return @config.hash
  end
  
  if RELEASE
    if config[:log]
      puts("INFO: Redirecting further output to log files")
      $stdout.reopen("#{EH::HOME_PATH}/info.log", "w")
      $stderr.reopen("#{EH::HOME_PATH}/error.log", "w")
    end
    if $DEBUG
      $DEBUG = false
    end
  end
  
  begin
    require "gl"
  rescue LoadError
    warn("WARNING: OpenGL gem not found, disabling shader support")
    config[:opengl] = false
  end

  
  # Graceful exit
  def self.exit(int)
    @config.save
    puts("INFO: Shutting down")
    Kernel.exit(int)
  end
  
end

# Few helper functions
class Numeric
  def even?
    if self % 2 == 0
      return true
    end
    return false
  end
  def to_b
    if self == 0
      return false
    else
      return true
    end
  end
  def inc
    + 1
  end
  def dec
    - 1
  end
end

class String
  def to_b
    if self == "true"
      return true
    else
      return false
    end
  end
  def to_pos
    ary = []
    ary.push(self.gsub(/\|\d+/, "").to_i)
    ary.push(self.gsub(/\d+\|/, "").to_i)
    return ary
  end
end

class TrueClass
  def to_i
    return 1
  end
end

class FalseClass
  def to_i
    return 0
  end
end

class Array
  def to_color
    return Gosu::Color.new(self[0], self[1], self[2], self[3])
  end
  def x
    return self[0]
  end
  def y
    return self[1]
  end
end

class Object
  alias ivg instance_variable_get
  alias ivs instance_variable_set
end

if !File.exists?("graphics/missing.png")
  puts("FATAL: Couldn't find graphics, exiting.")
  EH.exit(1)
end

puts("INFO: Loaded core module (v#{EH::VERSION})\nINFO: LIB #{EH::LIBRARY_PATH}\nINFO: HOME #{EH::HOME_PATH}")

require_relative "translate.rb"
require_relative "parse.rb"
require_relative "parse_tmx.rb"
require_relative "sample.rb"
require_relative "song.rb"
require_relative "sprite.rb"
require_relative "gui/base.rb"
require_relative "states/menus.rb"
require_relative "game/map/player.rb"
require_relative "game/npc/npc.rb"
require_relative "game/combat/battle.rb"
