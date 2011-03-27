
module EH::Game
  class Equipment < Hash
    @@locations = [
      :head,
      :torso,
      :larm,
      :rarm,
      :legs,
      :feet,
      :back,
    ]
    def initialize
      super
    end
    def equip(item, location, inventory)
      if @@locations.include?(location)
        inventory.remove(item)
        ret = self[location]
        inventory.add(ret) if ret
        self.store(location, item)
        return ret
      end
    end
    def remove_at(location)
      ret = self[location]
      self[location] = nil
      return ret
    end
    def at(loc)
      return self[loc]
    end
  end
end
