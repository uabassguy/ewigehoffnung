
# General system interface and common convenience functions

if (Gem::Version.new(RUBY_VERSION) <=> Gem::Version.new("1.9.0")) <= 0
  puts("WARNING: Ruby version (#{RUBY_VERSION}) is too old. Game may crash at any time.")
end

require "awesome_print"
require "gosu"

$:.push(".")

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
  MAP_Z = 1
  MAPOBJECT_Z = 50 
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
  
  @@fonts = {}
  
  def self.font(name, size)
    if @@fonts["#{name}-#{size}".to_sym]
      return @@fonts["#{name}-#{size}".to_sym]
    else
      @@fonts["#{name}-#{size}".to_sym] = Gosu::Font.new(EH.window, name, size)
    end
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
end

if !File.exists?("graphics/missing.png")
  puts("FATAL: Couldn't find graphics, exiting.")
  EH.exit(1)
end

puts("INFO: Loaded core module (v#{EH::VERSION})\nLIB #{EH::LIBRARY_PATH}\nHOME #{EH::HOME_PATH}")

require "translate.rb"
require "parse.rb"
require "sample.rb"
require "song.rb"
require "sprite.rb"
require "gui/base.rb"
require "states/menus.rb"
require "game/player.rb"
require "game/npc/npc.rb"
