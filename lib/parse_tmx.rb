
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
          properties.store(el.attribute("name").to_s.to_sym, el.attribute("value"))
        }
      }
      ap properties
      
      ts = root.get_elements("tileset")
      ts.each { |set|
        img = set.get_elements("image").first
        tile_props = {}
        tiles = set.get_elements("tile")
        tiles.each { |tile|
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
            img.attribute("source").to_s,
            tile_props)
        )
      }
      ap tilesets
      
      layers = root.get_elements("layer")
      layers.each { |layer|
        layer.each { |el|
        }
      }
      ap layers
      
      objectgrous = root.get_elements("objectgroup")
      objectgrous.each { |objectgroup|
        objectgroup.each { |el|
        }
      }
      return EH::Game::Map.new(properties, [], [])
    end
    
  end
  
end
