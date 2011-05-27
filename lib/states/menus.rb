
require_relative "states.rb"
require_relative "../gui/char_selector.rb"
require_relative "../gui/inventory.rb"
require_relative "../gui/item_info.rb"
require_relative "../gui/char_equip.rb"
require_relative "../gui/image.rb"
require_relative "../gui/textfield.rb"
require_relative "../gui/slider.rb"

module EH::States
  class StartMenu < State
    include EH
    def initialize(window)
      super(window)
      @background = EH.sprite("menu/start_background") # FIXME use window background
      @w = EH::GUI::Window.new(0, 0, 1024, 768, Trans.menu(:titlescreen_title), false)
      @w.add(:newgame, EH::GUI::Button.new(160, 544, 256, 64, Trans.menu(:newgame), lambda { EH.window.advance(GameState.new(EH.window)); @song.stop }, false))
      @w.add(:loadgame, EH::GUI::Button.new(608, 544, 256, 64, Trans.menu(:loadgame), lambda { EH.window.advance(LoadMenu.new(EH.window)) }, false))
      @w.add(:options, EH::GUI::Button.new(160, 640, 256, 64, Trans.menu(:options), lambda { EH.window.advance(OptionMenu.new(EH.window)) }, false))
      @w.add(:update, EH::GUI::Button.new(608, 640, 256, 64, Trans.menu(:update), lambda { EH.window.advance(UpdateMenu.new(EH.window)) }, false))
      @leaves = EH::Particles.new("title_leaves", 512, 0)
      @song = EH::Song.new("titlescreen")
      @song.play(true)
      @w.get(:loadgame).disable if Dir.entries("#{EH::HOME_PATH}saves/").join == "..."
    end
    def update
      update_cursor
      @w.update
      @leaves.update
    end
    def draw
      @background.draw(0, 0, 0)
      @w.draw
      @leaves.draw
      draw_cursor
    end
  end
  
  class OptionMenu < State
    include EH::GUI
    include EH
    def initialize(window)
      super(window)
      @background = EH.sprite("menu/ingame_background")
      @restart = false
      @w = EH::GUI::Window.new(0, 0, 1024, 768, Trans.menu(:options))
      @w.add(:details, Window.new(288, 56, 704, 128, Trans.menu(:options_details), false, "gui/options_details"))
      @w.add(:language, Button.new(32, 32, 224, 32, Trans.menu(:language), lambda {swap(:language)}, true, :left))
      @w.add(:volume, Button.new(32, 80, 224, 32, Trans.menu(:volume), lambda {swap(:volume)}, true, :left))
    end
    def swap(sym)
      detail = @w[:details]
      detail.empty
      case sym
      when :language
        detail.add(:en, Button.new(16, 16, 96, 24, Trans.menu(:lang_english), lambda {language(:en)}, true, :left))
        detail.add(:de, Button.new(16, 48, 96, 24, Trans.menu(:lang_german), lambda {language(:de)}, true, :left))
        detail[EH.config[:language].to_sym].disable
      when :volume
        detail.add(:slider, Slider.new(16, 16, 128, 32))
      end
    end
    def language(sym)
      EH.config[:language] = sym.to_s
      swap(:language)
      @restart = true
    end
    def update
      if @window.pressed?(Gosu::KbEscape) or @w.remove?
        if @restart
          EH.exit(0)
        else
          EH.window.advance(StartMenu.new(EH.window))
        end
      end
      @w.update
      if @restart and !@w[:details].include?(:warning)
        @w[:details].add(:warning, Textfield.new(384, 16, 320, 96, Trans.menu(:restart_warning)))
      end
      update_cursor
    end
    def draw
      @background.draw(0, 0, 0)
      @w.draw
      draw_cursor
    end
  end
  
  class IngameMenu < State
    include EH::GUI
    include EH
    def initialize(window, party)
      super(window)
      @background = EH.sprite("menu/ingame_background")
      @w = EH::GUI::Window.new(0, 0, 1024, 768, Trans.menu(:menu))
      @w.add(:items, Button.new(32, 32, 224, 32, Trans.menu(:items), lambda {}))
      @w.add(:equip, Button.new(32, 96, 224, 32, Trans.menu(:equipment), lambda { @window.advance(EquipMenu.new(@window, self, party)) }))
      @w.add(:skills, Button.new(32, 160, 224, 32, Trans.menu(:skills), lambda {}))
      @w.add(:magic, Button.new(32, 224, 224, 32, Trans.menu(:magic), lambda { @window.advance(MagicMenu.new(@window, self, party)) }))
      @w.add(:save, Button.new(32, 552, 224, 32, Trans.menu(:save), lambda {}))
      @w.add(:load, Button.new(32, 616, 224, 32, Trans.menu(:load), lambda {}))
      @w.add(:options, Button.new(32, 680, 224, 32, Trans.menu(:options), lambda {}))
    end
    def update
      if @window.pressed?(Gosu::KbEscape) or @w.remove?
        @window.load
      end
      update_cursor
      @w.update
    end
    def draw
      @background.draw(0, 0, 0)
      @w.draw
      draw_cursor
    end
  end
  
  class EquipMenu < State
    include EH::GUI
    include EH
    def initialize(window, previous, party)
      super(window)
      @previous = previous
      @party = party
      @background = EH.sprite("menu/ingame_background")
      @w = EH::GUI::Window.new(0, 0, 1024, 768, Trans.menu(:equipment))
      @w.add(:charselect, CharSelector.new(32, 32, party))
      @w.add(:inventory, Inventory.new(32, 96, 256, 360, @party.members[@w.get(:charselect).index], [:pants, :melee, :armor, :cloth, :ranged, :boots, :ammo]))
      @w.add(:iteminfo, ItemInfo.new(320, 32))
      @w.add(:itemdrop, ImageButton.new(32, 464, "gui/drop_item", lambda { drop_item }, 96, 96))
      @w.get(:itemdrop).disable
      @w.add(:equip, CharEquip.new(320, 224, @party.members[0]))
    end
    def update
      super
      if @window.pressed?(Gosu::KbEscape) or @w.remove?
        @window.advance(@previous)
      end
      @w.update
      if @w.get(:charselect).changed?
        @w.get(:inventory).inventory = @party.members[@w.get(:charselect).index].inventory
        @w.get(:iteminfo).item = nil
        @w.get(:itemdrop).disable
        @w.get(:equip).char = @party.members[@w.get(:charselect).index]
        @w.get(:equip).reset_slots
        @cursor.clear
      end
      if @w.get(:inventory).changed?
        @w.get(:iteminfo).item = @w.get(:inventory).selected
        @w.get(:itemdrop).enable
        ary = EH::Game.itemtype_to_locations(@w.get(:inventory).selected.type, @party.members[@w.get(:charselect).index].equipment)
        @w.get(:equip).highlight_slots(ary)
        @cursor.attach(@w.get(:inventory).selected.icon)
      end
      if @w.get(:equip).changed?
        @w.get(:inventory).assemble_items
        ary = EH::Game.itemtype_to_locations(@w.get(:inventory).selected.type, @party.members[@w.get(:charselect).index].equipment)
        @w.get(:equip).reset_slots
        if !@cursor.empty?
          @w.get(:equip).highlight_slots(ary)
        end
        @w.get(:equip).setup_equipment
      end
      if @w.get(:equip).equip?
        loc = @w.get(:equip).slot
        inv = @party.members[@w.get(:charselect).index].inventory
        equip = @party.members[@w.get(:charselect).index].equipment
        equip.equip(@w.get(:inventory).selected, loc, inv)
        @w.get(:iteminfo).item = nil
        @w.get(:itemdrop).disable
        @w.get(:equip).reset_slots
        @w.get(:equip).setup_equipment
        @w.get(:inventory).assemble_items
        @cursor.clear
      end
    end
    def draw
      @background.draw(0, 0, 0)
      @w.draw
      draw_cursor
    end
    # TODO ask for amount, right now it drops only one
    def drop_item
      @party.members[@w.get(:charselect).index].inventory.remove(@w.get(:inventory).selected)
      @w.get(:inventory).assemble_items
      @w.get(:iteminfo).item = nil
      @cursor.clear
      @w.get(:equip).reset_slots
      @w.get(:itemdrop).disable
    end
  end
  
  class MagicMenu < State
    include EH::GUI
    include EH
    def initialize(window, previous, party)
      super(window)
      @previous = previous
      @party = party
      @background = EH.sprite("menu/ingame_background")
      @w = EH::GUI::Window.new(0, 0, 1024, 768, Trans.menu(:magic))
      @w.add(:charselect, CharSelector.new(32, 32, party))
    end
    def update
      super
      if @window.pressed?(Gosu::KbEscape) or @w.remove?
        @window.advance(@previous)
      end
      @w.update
      if @w.get(:charselect).changed?
      end
    end
    def draw
      @background.draw(0, 0, 0)
      @w.draw
      draw_cursor
    end
  end
  
end