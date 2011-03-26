
module EH::Game
  class Item
    attr_reader :name, :desc, :icon, :weight, :effects, :type, :img
    def initialize(name, desc, icon, weight, effects=[], type=:item)
      @name, @desc, @weight, @effects, @type = name, desc, weight, effects, type
      @icon = EH::Sprite.new(EH.window, "icons/#{icon}")
      @img = EH::Sprite.new(EH.window, "items/#{icon}")
    end
  end
  
  def self.items
    return @items
  end
  
  def self.items=(ary)
    @items = ary
  end
  
  def self.find_item(name)
    @items.each { |item|
      if item.name == name
        return item
      end
    }
  end
  
  def self.itemtype_to_locations(type)
    ary = []
    case type
    when :armor
      ary = [:torso]
    when :cloth
      ary = [:torso]
    when :melee
      ary = [:larm, :rarm]
    when :pants
      ary = [:legs]
    when :boots
      ary = [:feet]
    when :ranged
      ary = [:rarm, :back]
    when :ammo
      ary = [:back]
    end
    return ary
  end
  
end
