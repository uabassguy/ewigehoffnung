
# Gosu::Image wrapper

module EH
  
  @@cache = {}
  def self.sprite(file, tile=false)
    if @@cache[file]
      return @@cache[file]
    end
    begin
      raise if !File.exist?("graphics/#{file}.png")
      img = Gosu::Image.new(window, "graphics/#{file}.png", tile)
      @@cache.store(file, img)
      return img
    rescue RuntimeError
      warn("ERROR: Failed to open graphic #{file}")
      file = "missing"
      retry
    end
  end
  
  # TODO cache
  def self.tiles(file, tx, ty, tile=false)
    begin
      ary = Gosu::Image.load_tiles(window, "graphics/#{file}.png", tx, ty, tile)
      return ary
    rescue RuntimeError
      warn("ERROR: Failed to open graphic #{file}")
      file = "missing"
      retry
    end
  end
  
end
