
require "states/states.rb"
require "gui/char_selector.rb"
require "gui/inventory.rb"
require "gui/item_info.rb"
require "gui/char_equip.rb"
require "gui/image.rb"

module EH::States
  class StartMenu < State
    include EH
    def initialize(window)
      super(window)
      @background = EH::Sprite.new(window, "menu/start_background")
      @w = EH::GUI::Window.new(self, 0, 0, 1024, 768, false)
      @w.title = Trans.menu(:titlescreen_title)
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
  
  class IngameMenu < State
    include EH::GUI
    include EH
    def initialize(window, party)
      super(window)
      @background = EH::Sprite.new(window, "menu/ingame_background")
      @w = EH::GUI::Window.new(self, 0, 0, 1024, 768)
      @w.title = Trans.menu(:menu)
      @w.add(:items, Button.new(32, 32, 224, 32, Trans.menu(:items), lambda {}))
      @w.add(:equip, Button.new(32, 96, 224, 32, Trans.menu(:equipment), lambda { @window.advance(EquipMenu.new(@window, self, party)) }))
      @w.add(:skills, Button.new(32, 160, 224, 32, Trans.menu(:skills), lambda {}))
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
      @background = EH::Sprite.new(window, "menu/ingame_background")
      @w = EH::GUI::Window.new(self, 0, 0, 1024, 768)
      @w.title = Trans.menu(:equipment)
      @w.add(:charselect, CharSelector.new(32, 32, party))
      @w.add(:inventory, Inventory.new(32, 96, 256, 360, @party.members[@w.get(:charselect).index], [:pants, :melee, :armor, :cloth, :ranged, :boots, :ammo]))
      @w.add(:iteminfo, ItemInfo.new(320, 32))
      @w.add(:itemdrop, ImageButton.new(32, 464, "drop_item", lambda { drop_item }, 96, 96))
      @w.get(:itemdrop).disable
      @w.add(:equip, CharEquip.new(320, 224, @party.members[0]))
    end
    def update
      if @window.pressed?(Gosu::KbEscape) or @w.remove?
        @window.advance(@previous)
      end
      update_cursor
      @w.update
      if @w.get(:charselect).changed?
        @w.get(:inventory).inventory = @party.members[@w.get(:charselect).index].inventory
        @w.get(:iteminfo).item = nil
        @w.get(:itemdrop).disable
        @w.get(:equip).char = @party.members[@w.get(:charselect).index]
        @w.get(:equip).reset_slots
      end
      if @w.get(:inventory).changed?
        @w.get(:iteminfo).item = @w.get(:inventory).selected
        @w.get(:itemdrop).enable
        ary = EH::Game.itemtype_to_locations(@w.get(:inventory).selected.type)
        @w.get(:equip).highlight_slots(ary)
      end
      if @w.get(:equip).changed?
        @w.get(:inventory).assemble_items
      end
    end
    def draw
      @background.draw(0, 0, 0)
      @w.draw
      draw_cursor
    end
    # TODO ask for amount, right now it drops everything
    def drop_item
      @party.members[@w.get(:charselect).index].inventory.remove(@w.get(:inventory).selected)
      @w.get(:inventory).assemble_items
      @w.get(:iteminfo).item = nil
      @w.get(:itemdrop).disable
    end
  end
  
end