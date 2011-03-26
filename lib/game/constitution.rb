
module EH::Game
  WOUND_LOCATIONS = [:head, :neck, :torso, :abdomen, :leg, :foot, :arm]
  class Wound
    attr_reader :location, :severity
    def initialize(location, severity)
      if !WOUND_LOCATIONS.include?(location)
        puts("WARNING: Unknown wound location #{location}")
      end
      @location = location
      @severity = severity
    end
    def location_factor
      case @location
      when :head
        return 5
      when :neck
        return 3
      when :torso
        return 2
      when :abdomen
        return 3
      when :leg
        return 1
      when :foot
        return 1
      when :arm
        return 2
      else
        return 1
      end
    end
  end
  
  class Constitution
    def initialize
      @wounds = []
    end
    # this shouldnt be called every frame, rather on each change of constitution
    def update(char)
      str = char.strength
      dmg = 0
      @wounds.each { |w|
        dmg += w.severity * w.location_factor
      }
    end
  end
end
