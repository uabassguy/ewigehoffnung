
module EH::GUI
  class Inventory < Container
    include EH
    ITEM_HEIGHT = 24
    def initialize(x, y, w, h, char, filter=[:all])
      super(x, y, w, h, ITEM_HEIGHT)
      @bg = EH::Sprite.new(EH.window, "gui/inventory_background")
      @inv = char.inventory
      @filter = filter
      @item = nil
      assemble_items
    end
    def assemble_items
      @items = []
      items = {}
      y = 0
      @inv.each { |item|
        if @filter.include?(:all) or @filter.include?(item.type)
          if items[item.name] != nil
            items[item.name][1] += 1
          else
            items.store(item.name, [item, 1])
          end
        end
      }
      items.each_value { |ary|
        item = ary[0]
        amount = ary[1]
        @items.push(Button.new(@x, @y+(y*ITEM_HEIGHT), @w-24, ITEM_HEIGHT, "#{amount}x #{Trans.item(item.name)}", lambda { clicked(item) }, false, :left))
        y += 1
      }
      if items.length <= @h/ITEM_HEIGHT
        @scrollbar.sh = @h
      else
        @scrollbar.sh = @scrollbar.h - ((@h/ITEM_HEIGHT)*items.length)
      end
    end
    def inventory=(inv)
      @inv = inv
      assemble_items
    end
    def update(window)
      super
      @items.each { |item|
        item.yoff = @content_offset/ITEM_HEIGHT
        if item.y + item.yoff < @y
          next
        elsif item.y + item.yoff + item.h > @y+@h
          next
        end
        item.update(window)
      }
    end
    def draw
      super
      @bg.img.draw(@x, @y, EH::GUI_Z, @w/@bg.width, @h/@bg.height.to_f)
      @items.each { |item|
        if item.y + item.yoff < @y
          next
        elsif item.y + item.yoff + item.h > @y+@h
          next
        end
        item.draw
      }
    end
    def selected
      return @item
    end
    def changed?
      if @changed
        @changed = false
        return true
      else
        return false
      end
    end
    private
    def clicked(item)
      @changed = true
      @item = item
    end
  end
end
