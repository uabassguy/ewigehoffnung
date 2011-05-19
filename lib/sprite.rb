
# Gosu::Image wrapper

module EH
  
  @@cache = {}
  def self.sprite(file, tile=false)
    if @@cache[file]
      return @@cache[file]
    end
    begin
      img = Gosu::Image.new(window, "graphics/#{file}.png", tile)
      @@cache.store(file, img)
      return img
    rescue RuntimeError
      warn("ERROR: Failed to open graphic #{file}")
      file = "missing"
      retry
    end
  end
  
end
