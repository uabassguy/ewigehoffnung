
# General interface to general game data

# Set up constants before loading any other files
module EH
  # System
  LIBRARY_PATH = File.dirname(__FILE__)
  HOME_PATH = "#{ENV["HOME"]}/.ewigehoffnung/"
  if !File.directory?(HOME_PATH)
    Dir.mkdir("#{ENV["HOME"]}/.ewigehoffnung")
  end
  if !File.directory?("#{HOME_PATH}saves")
    Dir.mkdir("#{HOME_PATH}saves")
  end
  VERSION = 0.1
  # Game
  MAPOBJECT_Z = 10 
  CURSOR_Z = 1000000
  GUI_Z = 9999
  PARTICLE_Z = 5000
  
  DEFAULT_FONT = "arial"
  
  DEFAULT_CONFIG = "default.cfg"
  
  @window = nil
  def self.window
    return @window
  end
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
  
  def self.ary_to_color(ary)
    return Gosu::Color.new(ary[0], ary[1], ary[2], ary[3])
  end
  
  require "config.rb"
  
  @config = Config.new
  @config.load
  def self.config
    return @config.hash
  end
  
  def self.exit(int)
    @config.save
    puts("INFO: Shutting down")
    Kernel.exit(int)
  end
  
end

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
end

class String
  def to_b
    if self == "true"
      return true
    else
      return false
    end
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

if !File.exists?("graphics/missing.png")
  puts("FATAL: Couldn't find graphics, exiting.")
  EH.exit(1)
end

puts("Loaded core module (v#{EH::VERSION})\nLIB #{EH::LIBRARY_PATH}\nHOME #{EH::HOME_PATH}")

require "translate.rb"
require "parse.rb"
require "sample.rb"
require "song.rb"
require "sprite.rb"
require "gui/base.rb"
require "states/menus.rb"
require "game/player.rb"
require "game/npc.rb"
