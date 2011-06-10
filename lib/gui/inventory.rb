
module EH::GUI
  class Inventory < Container
    include EH
    def initialize(x, y, w, h, char, filter=[:all], item_height=24)
      super(x, y, w, h, item_height)
      @item_height = item_height
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
        @items.push(Button.new(@x, @y+(y*@item_height), @w-24, @item_height, "#{amount}x #{Trans.item(item.name)}", lambda { clicked(item) }, false, :left, 24))
        y += 1
      }
    end
    
    def inventory=(inv)
      @inv = inv
      assemble_items
    end
    
  end
end
