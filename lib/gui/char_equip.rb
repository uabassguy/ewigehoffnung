
module EH::GUI
  
  class CharEquip < Element
    attr_reader :slot
    @@positions = {
      :head => [144, 72],
      :torso => [144, 160],
      :rarm => [80, 256],
      :larm => [208, 256],
      :legs => [144, 320],
      :feet => [144, 416],
      :back => [208, 96],
    }
    def initialize(x, y, c)
      super(x, y, 320, 512)
      @bg = EH.sprite("gui/charequip_background")
      @body = EH.sprite("gui/equip_#{c.race}")
      @font = EH.font(EH::DEFAULT_FONT, 24)
      @equipped = {}
      reset_slots
      @char = c
      @equip = false
      @changed = false
      setup_equipment
    end
    def char=(c)
      @char = c
      @body = EH.sprite("gui/equip_#{c.race}")
      setup_equipment
    end
    def reset_slots
      @slots = {}
      @colors = {}
      @@positions.each { |loc, pos|
        @slots.store(loc, ImageButton.new(@x+pos[0], @y+pos[1], "gui/equipslot_background", lambda {}))
      }
      @slots.each { |k, v|
        @colors.store(v, Gosu::Color.new(255, 255, 255, 255))
      }
    end
    def highlight_slots(ary)
      @colors = {}
      red = @slots
      green = {}
      ary.each { |loc|
        green.store(loc, red[loc])
        green[loc].proc = lambda { equip(loc) }
        red.delete(loc)
      }
      red.each_value { |img|
        color = Gosu::Color.new(255, 255, 0, 0)
        @colors.store(img, color)
      }
      green.each_value { |img|
        color = Gosu::Color.new(255, 0, 255, 0)
        @colors.store(img, color)
      }
      @slots = red.merge(green)
    end
    def setup_equipment
      equip = @char.equipment
      @equipped = {}
      equip.each { |loc, item|
        if item
          @equipped.store(loc, ImageButton.new(@x+@@positions[loc][0], @y+@@positions[loc][1], "#{item.icon_file}", lambda { unequip(loc) }, 32, 32))
        end          
      }
    end
    def equip(location)
      @equip = true
      @slot = location
    end
    def equip?
      if @equip
        @equip = false
        return true
      else
        return false
      end
    end
    def unequip(location)
      # TODO weight/capacity check
      @char.inventory.add(@char.equipment.remove_at(location))
      setup_equipment
      @changed = true
    end
    def update
      super
      @equipped.each_value { |el|
        el.update
      }
      @slots.each_value { |but|
        but.update
      }
    end
    def draw
      super
      @bg.draw(@x, @y, EH::GUI_Z + 5, @w/@bg.width.to_f, @h/@bg.height.to_f)
      @body.draw(@x+32, @y+32, EH::GUI_Z + 6, (@w-64)/@body.width.to_f, (@h-64)/@body.height.to_f)
      @slots.each_value { |but|
        but.bg.draw(but.x, but.y, EH::GUI_Z + 10, 1, 1, @colors[but])
      }
      @equipped.each_value { |el|
        el.draw
      }
    end
    def changed?
      if @changed
        @changed = false
        return true
      else
        return false
      end
    end
  end
  
end
