
module EH::Game
  module Alchemy
    
    class Recipe
      attr_accessor :name, :icon, :output, :input, :level
    end
  
    def self.recipies
      return @recipies
    end
  
    def self.recipies=(ary)
      @recipies = ary
    end
  
    def self.find_recipe(name)
      @recipies.each { |item|
        if item.name == name
          return item
        end
      }
    end
    
  end
end
