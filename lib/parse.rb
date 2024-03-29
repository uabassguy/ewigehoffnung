
# Parsers

require_relative "game/map/map.rb"
require_relative "game/item.rb"
require_relative "game/spell.rb"
require_relative "game/alchemy/recipe.rb"

require_relative "tileset.rb"
require_relative "layer.rb"

require_relative "game/npc/behaviour.rb"

# TODO function to look for key in a line and return it; then refactor

module EH::Parse
  
  class Parser
    def initialize(file, parsables, klass, stfu=false)
      begin
        @file = File.open(file)
      rescue
        warn("ERROR: Failed to open file #{file}")
      end
      @parsables = parsables
      @klass = klass
      @stfu = stfu
    end
    
    def parse
      parsed = []
      vars = []
      block = false
      
      @parsables.each_key { |str|
        vars.push("@#{str}_parsed".to_sym)
      }
        
      @file.each_line { |line|
        line.sub!("\n", "")
        if line[0] == "#" or line.length == 0
          break if line.index("#EOF")
          next
        end
        if line[0] == "{"
          block = true
          next
        end
        if line[0] == "}"
          block = false
          parsed.push(@klass.send(:new))
          vars.each { |var|
            parsed.last.ivs(var.to_s[0...-7].to_sym, ivg(var))
          }
          next
        end
        if block
          line.gsub!("\"", "")
          line =~ /(.+)\s\=\s(.+)/
          key = $1
          val = cast_type($2, @parsables[key])
          ivs("@#{key}_parsed".to_sym, val)
        end
      }
      if !@stfu
        puts("INFO: Parsed #{parsed.length} #{File.basename(@file).sub('.def', '')}")
      end
      @file.close
      return parsed
    end
    
    private
    
    def eval_type(sym)
      case sym
      when :string
        return ""
      when :symbol
        return :nil
      when :int
        return 0
      when :float
        return 0.0
      when :array, :symarray, :intarray
        return []
      when :color
        return Gosu::Color::WHITE
      end
    end
    
    def cast_type(str, sym)
      case sym
      when :string
        return str
      when :symbol
        return str.to_sym
      when :int
        return str.to_i
      when :float
        return str.to_f
      when :array
        s = str.gsub!(/\s|\[|\]/, '')
        ary = s.split(',')
        ary.each { |el|
          if el.include?('*')
            a = el.split('*')
            ary.delete(el)
            a[0].to_i.times {
              ary.push(a[1])
            }
          end
        }
        return ary
      when :symarray
        s = str.gsub!(/\s|\[|\]/, '')
        ary = s.split(',')
        ary.each { |el|
          if el.include?('*')
            a = el.split('*')
            ary.delete(el)
            a[0].to_i.times {
              ary.push(a[1])
            }
          end
        }
        return ary.map(&:to_sym)
      when :intarray
        s = str.gsub!(/\s|\[|\]/, '')
        ary = s.split(',')
        ary.each { |el|
          if el.include?('*')
            a = el.split('*')
            ary.delete(el)
            a[0].to_i.times {
              ary.push(a[1])
            }
          end
        }
        return ary.map(&:to_i)
      when :color
        s = str.gsub!(/\s|\[|\]/, '')
        ary = s.split(',')
        ary.each { |el|
          if el.include?('*')
            a = el.split('*')
            ary.delete(el)
            a[0].to_i.times {
              ary.push(a[1])
            }
          end
        }
        ary = ary.map(&:to_i)
        color = Gosu::Color.new(ary[3], ary[0], ary[1], ary[2])
        return color
      when :image
        return EH.sprite(str)
      end
    end
  end
  
  def self.map(file, tiny=false)
    return EH::Parse::TMX.parse(file)
  end
  
  # TODO create special parser
  def self.particles
    hash = {}
    begin
      file = File.open("def/particles.def")
    rescue
      warn("ERROR: Couldn't find particles.def")
      return hash
    end
    block = false
    
    name = filename = ""
    mode = :default
    delay = time = fadein = fadeout = 0
    color = 0xffffffff
    xrange = yrange = xoffset = yoffset = (0..0)
    angle = false
    
    file.each_line { |line|
      line.sub!("\n", "")
      if line[0] == "#" or line.length == 0
        break if line.index("#EOF")
        next
      end
      if line[0] == "{"
        block = true
      end
      if line[0] == "}"
        block = false
        hash.store(name.to_sym, EH::ParticleEmitter.new(filename, time, fadein, fadeout, color, delay, angle, mode, xrange, yrange, xoffset, yoffset))
        name = filename = ""
        mode = :default
        delay = time = fadein = fadeout = 0
        color = 0xffffffff
        xrange = yrange = xoffset = yoffset = (0..0)
        angle = false
      end
      if block
        if line.start_with?("name")
          line.gsub!(/name *= */, "")
          name = line.gsub("\"", "")
        elsif line.start_with?("file")
          line.gsub!(/file *= */, "")
          filename = line.gsub("\"", "")
        elsif line.start_with?("delay")
          line.gsub!(/delay *= */, "")
          delay = line.gsub("\"", "").to_i
        elsif line.start_with?("time")
          line.gsub!(/time *= */, "")
          time = line.gsub("\"", "").to_i
        elsif line.start_with?("fadein")
          line.gsub!(/fadein *= */, "")
          fadein = line.gsub("\"", "").to_i
        elsif line.start_with?("fadeout")
          line.gsub!(/fadeout *= */, "")
          fadeout = line.gsub("\"", "").to_i
        elsif line.start_with?("mode")
          line.gsub!(/mode *= *:/, "")
          mode = line.gsub("\"", "").to_sym
        elsif line.start_with?("color")
          line.gsub!(/color *= */, "")
          color = parse_int_array(line.gsub("\"", "")).to_color
        elsif line.start_with?("angle")
          line.gsub!(/angle *= */, "")
          angle = line.gsub("\"", "").to_b
        elsif line.start_with?("xrange")
          line.gsub!(/xrange *= */, "")
          xrange = parse_range(line.gsub("\"", ""))
        elsif line.start_with?("yrange")
          line.gsub!(/yrange *= */, "")
          yrange = parse_range(line.gsub("\"", ""))
        elsif line.start_with?("xoffset")
          line.gsub!(/xoffset *= */, "")
          xoffset = parse_range(line.gsub("\"", ""))
        elsif line.start_with?("yoffset")
          line.gsub!(/yoffset *= */, "")
          yoffset = parse_range(line.gsub("\"", ""))
        end
      end
    }
    puts("INFO: Parsed #{hash.length} particles")
    return hash
  end
  
  def self.parse_range(str)
    r = (0..0)
    str.gsub!("(", "")
    str.gsub!(")", "")
    first = last = 0
    first = str.gsub(/\D{2,}.+/, "").to_i
    last = str.gsub(/-?\d+\D{2}/, "").to_i
    r = (first..last)
    return r
  end
  
  def self.parse_sym_array(str)
    ary = []
    str.gsub!("[", "")
    str.gsub!("]", "")
    str.gsub!(" ", "")
    str.each_line(",") { |c|
      ary.push(c.sub(",", "").to_sym)
    }
    return ary
  end
  
  def self.parse_int_array(str)
    ary = []
    str.gsub!("[", "")
    str.gsub!("]", "")
    str.gsub!(" ", "")
    str.each_line(",") { |c|
      ary.push(c.sub(",", "").to_i)
    }
    return ary
  end
  
  def self.behaviour(map, npc)
    begin
      file = File.open("maps/def/#{map}.bhv", "r")
      block = ary = false
      
      b = nil
      
      name = array = type = ""
      init = trigger = motion = update = EH::Game::NPC::Task.new([])
      
      file.each_line { |line|
        line.sub!("\n", "")
        if line[0] == "#" or line.length == 0
          if line == "#EOF"
            break
          end
          next
        end
        line.lstrip!
        if ary
          if line == "]"
            array.gsub!("<", "")
            array.gsub!(">", "")
            ret = self.task_array(array.split("?"), npc)
            # TODO needs some magic
            case type
            when "init"
              init = ret
            when "trigger"
              trigger = ret
            when "motion"
              motion = ret
            when "update"
              update = ret
            end
            array = ""
            ary = false
            next
          end
          array += "#{line}?"
          next
        end
        if block
          if line.include?("}")
            block = false
            b = EH::Game::NPC::Behaviour.new(npc, init, trigger, motion, update)
            init = trigger = motion = update = EH::Game::NPC::Task.new([])
            break
          end
          type = line.gsub(/\s?=\s?\[/, "")
          ary = true
        else
          if line.include?("{")
            block = true
            name = line.gsub(/\s?\{/, "")
            if npc.properties[:id] != name
              ary = block = false
              next
            end
          end
        end
      }
      file.close
    rescue Errno::ENOENT
      # we dont care about missing definition files
    end
    return b
  end
  
  def self.task_array(inp, npc)
    ret = []
    inp.each { |el|
      delete = []
      ary = el.split(" ")
      ary.each { |parm|
        if parm.include?("|")
          if parm.include?("@")
            parm.sub!("@x", "#{npc.x}")
            parm.sub!("@y", "#{npc.y}")
          end
          ary[ary.index(parm)] = parm.to_pos
          next
        elsif ary.first == :msg and parm.include?(":")
          ary[ary.index(parm)] = EH::Trans.dialogue(parm.gsub(":", "").to_sym)
          next
        end
        ary[ary.index(parm)] = parm.to_sym
      }
      ary.compact!
      ret.push(ary)
    }
    ret.compact!
    return EH::Game::NPC::Task.new(ret)
  end
  
  # TODO create special parser
  def self.enemy_behaviour(name)
    hash = {}
    begin
      file = File.open("def/enemies/#{name}.bhv")
    rescue
      warn("ERROR: Couldn't find enemies/#{name}.bhv")
      return hash
    end
    
    actions = [:on_turn, :on_defeat]
    number = 0
    block = false
    
    action = nil
    ary = []
    
    file.each_line { |line|
      number += 1
      line.gsub!("\n", "")
      if line[0] == "#" or line.length == 0
        if line == "#EOF"
          break
        end
        next
      end
      if line[0] == "{"
        block = true
      elsif line[0] == "}" and block and action
        hash.store(action, ary)
        action = nil
        ary = []
        block = false
        next
      else
        if !action and !block
          action = line.gsub("\"", "").to_sym
          if !actions.include?(action)
            warn("WARNING: Unknown action key #{action} at enemies/#{name}.bhv, line #{number}")
            action = nil
            block = false
          end
        elsif block and action
          ary.push(line.gsub("\"", ""))
        end
      end
    }
    file.close
    return EH::Game::Combat::Behaviour.new(hash)
  end
  
  def self.characters
    p = {
      "name" => :string,
      "age" => :int,
      "strength" => :int,
      "weight" => :int,
      "agility" => :int,
      "file" => :string,
      "race" => :string,
      "gender" => :symbol,
      "healing" => :int,
      "crafting" => :int,
      "botany" => :int,
      "healing_magic" => :int,
      "mind" => :int,
      "elemental" => :int,
      "ranged" => :int,
      "melee" => :int,
    }
    chars = Parser.new("def/characters.def", p, EH::Game::Character).parse
    chars.each { |char|
      char.setup
      char.validate
    }
    return chars
  end
  
  def self.skills
    p = {
      "name" => :symbol,
      "icon" => :image,
    }
    return Parser.new("def/skills.def", p, EH::Game::Skill).parse
  end
  
  def self.recipies
    p = {
      "name" => :symbol,
      "icon" => :image,
      "output" => :symbol,
      "input" => :symarray,
      "level" => :int,
    }
    return Parser.new("def/recipies.def", p, EH::Game::Alchemy::Recipe).parse
  end
  
  def self.items
    p = {
      "name" => :symbol,
      "icon" => :string,
      "weight" => :float,
      "effects" => :symarray,
      "type" => :symbol,
    }
    items = Parser.new("def/items.def", p, EH::Game::Item).parse
    items.each { |item|
      icon = item.icon
      item.ivs("@icon".to_sym, EH.sprite("icons/items/#{icon}"))
      item.ivs("@icon_file".to_sym, "icons/items/#{icon}")
      item.ivs("@img".to_sym, EH.sprite("items/#{icon}"))
    }
    return items
  end
  
  def self.spells
    p = {
      "name" => :symbol,
      "icon" => :image,
      "type" => :symbol,
      "cost" => :int,
    }
    return Parser.new("def/spells.def", p, EH::Game::Spell).parse
  end
  
  def self.enemies
    p = {
      "name" => :symbol,
      "file" => :image,
      "type" => :symbol,
      "strength" => :int,
      "weapons" => :symarray,
    }
    return Parser.new("def/enemies.def", p, EH::Game::Combat::Enemy).parse
  end
  
  # TODO create special parser
  def self.weapons
    hash = {}
    begin
      file = File.open("def/weapons.def")
    rescue
      warn("ERROR: Couldn't find weapons.def")
      return hash
    end
    block = false
    
    name = icon = ""
    type = :melee
    effects = []
    
    file.each_line { |line|
      line.gsub!("\n", "")
      if line[0] == "#" or line.length == 0
        if line == "#EOF"
          break
        end
        next
      end
      if line[0] == "{"
        block = true
      end
      if line[0] == "}"
        block = false
        hash.store(name, EH::Game::Combat::Weapon.new(name, type, effects, icon))
        next
      end
      if block
        if line.start_with?("icon")
          line.gsub!(/icon *= */, "")
          icon = line.gsub("\"", "")
        elsif line.start_with?("type")
          line.gsub!(/type *= */, "")
          type = line.gsub("\"", "").to_sym
        elsif line.start_with?("effects")
          line.gsub!(/effects *= */, "")
          effects = parse_sym_array(line.gsub("\"", ""))
        end
      else
        name = line.gsub("\"", "").to_sym
      end
    }
    file.close
    puts("INFO: Parsed #{hash.size} weapons")
    return hash
  end
  
  # FIXME bit hacked
  def self.animations
    p = {
      "length" => :int,
      "color" => :color,
      "x" => :float,
      "y" => :float,
      "mode" => :symbol,
    }
    anims = {}
    Dir.new("def/animations").each { |file|
      next if file == "." or file == ".."
      frames = Parser.new("def/animations/#{file}", p, EH::Frame, true).parse
      block = false
      @graphic = @split_x = @split_y = @repeat = nil
      f = File.open("def/animations/#{file}")
      f.each_line { |line|
        line.gsub!(" ", "")
        if line[0] == '('
          block = true
          next
        end
        if block
          if line[0] == ')'
            anims.store(file.gsub(".anim", "").to_sym, EH::Animation.new(@graphic, @split_x.to_i, @split_y.to_i, @repeat.to_b, frames))
            break
          else  
            line.gsub!("\"", "")
            line =~ /(.+)\=(.+)/
            key = $1
            val = $2
            ivs("@#{key}", val)
          end
        end
      }
      f.close
    }
    puts("INFO: Parsed #{anims.size} animations")
    return anims
  end
  
  def animation(file)
    graphic = ""
    sx = sy = 0
    repeat = false
    frames = []
    return Animation.new(graphic, sx, sy, repeat, frames)
  end
  
end
