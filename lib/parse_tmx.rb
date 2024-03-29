
require "rexml/document"

module EH::Parse
  
  module TMX
    
    include REXML
  
    def self.parse(file)
      f = File.open("maps/#{file}.tmx", "r")
      doc = Document.new(f)
      f.close
      root = doc.root
      properties = {}
      tilesets = []
      layers = []
      objects = []
      
      props = root.get_elements("properties")
      props.each { |prop|
        prop.each_element { |el|
          properties.store(el.attribute("name").to_s.to_sym, el.attribute("value").to_s)
        }
      }
      properties.store(:width, root.attribute("width").to_s.to_i)
      properties.store(:height, root.attribute("height").to_s.to_i)
      properties.store(:file, file)
      
      ts = root.get_elements("tileset")
      ts.each { |set|
        img = set.get_elements("image").first
        tile_props = {}
        set.get_elements("tile").each { |tile|
          hash = {}
          tile.get_elements("properties/property").each { |p|
            hash.store(p.attribute("name").to_s.to_sym, p.attribute("value").to_s)
          }
          tile_props.store(tile.attribute("id").to_s.to_i, hash)
        }
        tilesets.push(
          EH::Tileset.new(
            set.attribute("firstgid"),
            set.attribute("name"),
            "graphics/tiles/#{File.basename(img.attribute("source").to_s)}",
            tile_props)
        )
      }
      
      layer_elements = root.get_elements("layer")
      layer_elements.each { |layer|
        w = layer.attribute("width").to_s.to_i
        h = layer.attribute("height").to_s.to_i
        props = {:name => layer.attribute("name").to_s}
        layer.get_elements("properties/property").each { |el|
          props.store(el.attribute("name").to_s.to_sym, el.attribute("value").to_s)
        }
        data = layer.get_elements("data").first
        tiles = []
        line = data.text.gsub("\n", "")
        line.each_line(",") { |val|
          tiles.push(val.gsub(",", "").to_i)
        }
        layers.push(EH::Layer.new(w, h, props, tiles))
        layers.last.fill_tilemap(tilesets.last)
      }
      
      objectgrous = root.get_elements("objectgroup")
      objectgrous.each { |objectgroup|
        objectgroup.each_element { |el|
          x = el.attribute("x").to_s.to_i
          y = el.attribute("y").to_s.to_i
          props = {}
          el.get_elements("properties/property").each { |p|
            props.store(p.attribute("name").to_s.to_sym, p.attribute("value").to_s)
          }
          props.store(:layer, objectgroup.attributes["name"])
          props.store(:id, el.attribute("name").to_s.gsub("-", "_"))
          case el.attribute("type").to_s.to_sym
          when :npc
            obj = EH::Game::MapNPC.new(x, y, props)
            obj.behaviour = EH::Parse.behaviour(file, obj)
          else
            obj = EH::Game::MapObject(x, y, props)
          end
          objects.push(obj)
        }
      }
      
      return EH::Game::Map.new(properties, layers, objects)
    end
    
  end
  
end
