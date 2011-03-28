
# Parsers

require "game/map.rb"
require "game/item.rb"

require "rexml/document"
require "tileset.rb"
require "layer.rb"

module EH::Parse
  include REXML
  def self.map(file)
    tiles = []
    layers = []
    objects = []
    f = File.open("maps/#{file}.tmx", "r")
    doc = Document.new(f)
    f.close
    root = doc.root
    properties = self.xml_properties(root.elements["properties[1]"])
    properties.store(:width, root.attributes["width"].to_i)
    properties.store(:height, root.attributes["height"].to_i)
    root.each_element("//tileset") { |el|
      tiles.push(self.tileset(el))
    }
    root.each_element("//layer") { |el|
      layers.push(self.layer(el))
      layers.last.fill_tilemap(tiles[0])
      layers.last.clean # save a little memory :)
    }
    root.each_element("//objectgroup") { |el|
      objects += self.objectgroup(el)
    }
    #awesome_print(properties)
    #tiles.each { |t|
    #  awesome_print(t.create_tiles)
    #}
    #awesome_print(layers)
    #awesome_print(objects)
    return EH::Game::Map.new(properties, layers, objects)
  end
  
  def self.xml_properties(el)
    hash = {}
    el.each_element("property") { |prop|
      hash.store(prop.attributes["name"].to_sym, prop.attributes["value"])
    }
    return hash
  end
  
  def self.xml_csv(data)
    ary = []
    line = data.text.gsub("\n", "")
    line.each_line(",") { |val|
      ary.push(val.gsub(",", "").to_i)
    }
    return ary
  end
  
  def self.xml_base64_zlib(data)
    puts("ERROR: base64 zlib decoding not supported yet")
  end
  
  def self.tileset(el)
    file = el.elements["//image"].attributes["source"]
    file = "graphics/tiles/#{File.basename(file)}"
    props = {}
    el.each_element("//tile") { |e|
      id = e.attributes["id"].to_i
      props.store(id, self.xml_properties(e.elements["properties[1]"]))
    }
    return EH::Tileset.new(el.attributes["firstgid"], el.attributes["name"], file, props)
  end
  
  def self.layer(el)
    props = self.xml_properties(el.elements["properties[1]"])
    case el.elements["data[1]"].attributes["encoding"]
    when "csv"
      tiles = self.xml_csv(el.elements["data[1]"])
    when "base64"
      if el.elements["data[1]"].attributes["compression"] != "zlib"
        puts("ERROR: Unsupported layer compression (must be zlib)")
      else
        tiles = self.xml_base64_zlib(el.elements["data[1]"])
      end
    else
      puts("ERROR: Unsupported layer encoding (must be csv or base64)")
    end
    tiles = [] if !tiles
    return EH::Layer.new(el.attributes["width"].to_i, el.attributes["height"].to_i, props, tiles)
  end
  
  def self.objectgroup(el)
    ary = []
    el.each_element("object") { |obj|
      props = self.xml_properties(obj.elements["properties[1]"])
      ary.push(EH::Game::MapObject.new(obj.attributes["x"].to_i, obj.attributes["y"].to_i, props))
    }
    return ary
  end
  
  def self.characters
    ary = []
    begin
      file = File.open("def/characters.def")
    rescue
      puts("ERROR: Couldn't find characters.def")
      return ary
    end
    block = false
    
    name = charset = race = ""
    age = weight = strength = 0
    gender = :male
        
    file.each_line { |line|
      line.gsub!("\n", "")
      if line.start_with?("#") or line.length == 0
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
        ary.push(EH::Game::Character.new(name, charset, age, weight, strength, gender, race))
        name = charset = race = ""
        gender = :male
        age = weight = strength = 0
      end
      if block
        if line.start_with?("name")
          line.gsub!(/name *= */, "")
          name = line.gsub("\"", "")
        elsif line.start_with?("file")
          line.gsub!(/file *= */, "")
          charset = line.gsub("\"", "")
        elsif line.start_with?("race")
          line.gsub!(/race *= */, "")
          race = line.gsub("\"", "")
        elsif line.start_with?("strength")
          line.gsub!(/strength *= */, "")
          strength = line.gsub("\"", "").to_i
        elsif line.start_with?("age")
          line.gsub!(/age *= */, "")
          age = line.gsub("\"", "").to_i
        elsif line.start_with?("gender")
          line.gsub!(/gender *= */, "")
          gender = line.gsub("\"", "").to_sym
        end
      end
    }
    puts("INFO: Parsed #{ary.size} characters")
    return ary
  end
  def self.skills
    ary = []
    begin
      file = File.open("def/skills.def")
    rescue
      puts("ERROR: Couldn't find skills.def")
      return ary
    end
    block = false
    name = desc = icon = ""
    file.each_line { |line|
      line.gsub!("\n", "")
      if line.start_with?("#") or line.length == 0
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
        ary.push(EH::Game::Skill.new(name, desc, icon))
        name = desc = icon = ""
      end
      if block
        if line.start_with?("name")
          line.gsub!(/name *= */, "")
          name = line.gsub("\"", "")
        elsif line.start_with?("desc")
          line.gsub!(/desc *= */, "")
          desc = line.gsub("\"", "")
        elsif line.start_with?("icon")
          line.gsub!(/icon *= */, "")
          icon = line.gsub("\"", "")
        end
      end
    }
    puts("INFO: Parsed #{ary.size} skills")
    return ary
  end
  def self.items
    ary = []
    begin
      file = File.open("def/items.def")
    rescue
      puts("ERROR: Couldn't find items.def")
      return ary
    end
    block = false
    name = desc = icon = type = ""
    weight = 0.0
    effects = []
    file.each_line { |line|
      line.gsub!("\n", "")
      if line.start_with?("#") or line.length == 0
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
        ary.push(EH::Game::Item.new(name, desc, icon, weight, effects, type))
        name = desc = icon = ""
      end
      if block
        if line.start_with?("name")
          line.gsub!(/name *= */, "")
          name = line.gsub("\"", "")
        elsif line.start_with?("desc")
          line.gsub!(/desc *= */, "")
          desc = line.gsub("\"", "")
        elsif line.start_with?("icon")
          line.gsub!(/icon *= */, "")
          icon = line.gsub("\"", "")
        elsif line.start_with?("weight")
          line.gsub!(/weight *= */, "")
          weight = line.gsub("\"", "").to_f
        elsif line.start_with?("effects")
          line.gsub!(/effects *= */, "")
          effects = parse_sym_array(line.gsub("\"", ""))
        elsif line.start_with?("type")
          line.gsub!(/type *= */, "")
          type = line.gsub("\"", "").to_sym
        end
      end
    }
    puts("INFO: Parsed #{ary.size} items")
    return ary
  end
  def self.particles
    hash = {}
    begin
      file = File.open("def/particles.def")
    rescue
      puts("ERROR: Couldn't find particles.def")
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
      line.gsub!("\n", "")
      if line.start_with?("#") or line.length == 0
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
        hash.store(name, EH::ParticleEmitter.new(filename, time, fadein, fadeout, color, delay, angle, mode, xrange, yrange, xoffset, yoffset))
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
          color = EH.ary_to_color(parse_int_array(line.gsub("\"", "")))
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
      ary.push(c.to_sym)
    }
    return ary
  end
  def self.parse_int_array(str)
    ary = []
    str.gsub!("[", "")
    str.gsub!("]", "")
    str.gsub!(" ", "")
    str.each_line(",") { |c|
      ary.push(c.to_i)
    }
    return ary
  end
end