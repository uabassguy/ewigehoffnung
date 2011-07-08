
module EH::States
  
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
  
end
