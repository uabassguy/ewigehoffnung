
module EH::GUI
  class Inventory < Container
    include EH
    ITEM_HEIGHT = 24
    def initialize(x, y, w, h, char, filter=[:all])
      super(x, y, w, h, ITEM_HEIGHT)
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
    end
  end
end
