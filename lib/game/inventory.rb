
module EH::Game
  # strength is an arbitrary unit; in this context it's 1 str == 1 kg of carrying
  class Inventory < Array
    attr_accessor :capacity, :strength
    def initialize(capacity, strength)
      super(capacity)
      @capacity = capacity
      @strength = strength
      self.clear
    end
    def add(item)
      if self.size + 1 < @capacity and item.weight + weight < @strength
        self.push(item)
      end
    end
    def remove(item, times=1)
      removed = 0
      self.each { |other_item|
        if other_item.name == item.name
          self.delete(other_item)
          removed += 1
        end
        if removed >= times
          return
        end
      }
    end
    def weight
      weight = 0
      self.each { |item|
        weight += item.weight
      }
      return weight
    end
  end
end
