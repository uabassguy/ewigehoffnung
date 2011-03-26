
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
    def initialize(name, desc, icon)
      @name = name
      @desc = desc
      @img = EH::Sprite.new(EH.window, "skills/#{icon}")
    end
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
  end
end
