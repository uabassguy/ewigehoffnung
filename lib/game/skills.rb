
module EH::Game
  @skills = []
  
  def self.skills
    return @skills
  end
  
  def self.skills=(ary)
    @skills = ary
  end
  
  def self.find_skill(name)
    @skills.each { |skill|
      if skill.name == name
        return skill
      end
    }
  end
  
  class Skill
    attr_reader :name, :desc, :img
  end
  
  # skills and their respective levels, instanced once for every character
  class Skills
    def initialize
      @skills = {}
      EH::Game.skills.each { |skill|
        @skills.store(skill, 0)
      }
    end
    
    def list
      return @skills
    end
    
    def advance(skill)
      @skills.each { |s|
        if skill.class == s.class
          @skills[s] += 1
        end
      }
    end
    
    def level_to_s(skill)
      lvl = @skills[skill]
      case lvl
      when 0
        return EH::Trans.menu(:xp_none)
      when 1
        return EH::Trans.menu(:xp_vlittle)
      when 2
        return EH::Trans.menu(:xp_little)
      when 3
        return EH::Trans.menu(:xp_mediocre)
      when 4
        return EH::Trans.menu(:xp_experienced)
      when 5
        return EH::Trans.menu(:xp_vexperienced)
      end
    end
  end
end
