
module EH::Game
  require_relative "../../ext/astar/node.rb"
  require_relative "../../ext/astar/priority_queue.rb"
  require_relative "tile.rb"
  
  class Map
    attr_reader :props, :layers, :properties
    attr_accessor :xoff, :yoff, :objects
    def initialize(props, layers, objects)
      @properties = props
      @layers = layers
      @objects = objects
      @xoff = @yoff = 0
      create_static_collision
    end
    
    def width
      return @properties[:width]
    end
    
    def height
      return @properties[:height]
    end
    
    def create_static_collision
      tiles = []
      @layers.each { |l|
        i = 0
        l.filled.each { |row|
          row.each { |tile|
            if !tile
              if tiles[i] == false
                i += 1
                next
              else
                tiles[i] = true
                i += 1
                next
              end
            end
            tiles[i] = tile.passable?
            i += 1
          }
        }
      }
      @collision = EH::CollisionLayer.new(@layers.first.filled.first.size, @layers.first.filled.size, tiles)
    end
    
    # parameters are scrolling, instance variables are world positions
    def draw(xoff, yoff)
      @layers.each { |l|
        l.filled.each { |ary|
          ary.each { |tile|
            tile.draw(xoff+@xoff, yoff+@yoff) if tile
          }
        }
      }
    end
    
    def passable?(x, y)
      if (x/32) < 0 or (x/32) > @collision.tiles.first.size-1 or (y/32) < 0 or (y/32) > @collision.tiles.size-1
        return false
      end
      p = @collision.tiles[y/32][x/32]
      if p
        obj = EH.window.state.find_object(x, y)
        if !obj
          return true
        end
        p = obj.through
      end
      return p
    end
    
    def generate_costmap
      map = []
      x = 0
      @collision.tiles.each { |ary|
        cary = []
        y = 0
        ary.each { |tile|
          if tile
            obj = EH.window.state.find_object(y*32, x*32)
            if obj and !obj.through
              cary.push(0)
              y += 1
              next
            end
            cary.push(1)
          else
            cary.push(0)
          end
          y += 1
        }
        map.push(cary)
        x += 1
      }
      return map
    end
    
    def generate_successor_nodes(anode, costmap)
      height = costmap.size
      width = costmap.first.size
      # determine nodes bordering this one - only N,S,E,W for now
      # no boundary condition check, eg if anode.x==-4
      # considers a wall to be a 0 so therefore not allow that to be a neighbour
      north = costmap[anode.y-1][anode.x] unless (anode.y-1) < 0 #boundary check for -1
      south = costmap[anode.y+1][anode.x] unless (anode.y+1) > (height - 1)
      east  = costmap[anode.y][anode.x+1] unless (anode.x+1) > (width - 1)
      west  = costmap[anode.y][anode.x-1] unless (anode.x-1) < 0 #boundary check for -1
      
      if (west && west > 0) # not on left edge, so provide a left-bordering node
        newnode = AStar::Node.new((anode.x-1),anode.y,costmap[anode.y][(anode.x-1)])
        yield newnode
      end
      if (east && east > 0) # not on right edge, so provide a right-bordering node
        newnode = AStar::Node.new((anode.x+1),anode.y,costmap[anode.y][(anode.x+1)])
        yield newnode
      end
      if (north && north > 0) # not on left edge, so provide a left-bordering node
        newnode = AStar::Node.new(anode.x,(anode.y-1),costmap[(anode.y-1)][anode.x])
        yield newnode
      end
      if (south && south > 0) # not on right edge, so provide a right-bordering node
        newnode = AStar::Node.new(anode.x,(anode.y+1),costmap[(anode.y+1)][anode.x])
        yield newnode
      end    
    end
  
    def astar(node_start, node_goal)
      iterations = 0
      open = AStar::PriorityQueue.new()
      closed = AStar::PriorityQueue.new()
      node_start.calc_h(node_goal)
      open.push(node_start)
      costmap = generate_costmap
      while !open.empty? do
        iterations += 1 #keep track of how many times this itersates
        node_current = open.find_best
        if node_current == node_goal
          #puts("Iterations: #{iterations}")
          #show_path(node_current)
          return node_current 
        end       
        generate_successor_nodes(node_current, costmap) { |node_successor|
          #now doing for each successor node of node_current
          node_successor.calc_g(node_current)
          #skip to next node_successor if better one already on open or closed list
          if open_successor=open.find(node_successor) then 
            if open_successor<=node_successor then next end  #need to account for nil result
          end
          if closed_successor=closed.find(node_successor) then
            if closed_successor<=node_successor then next end 
          end
          #still here, then there's no better node yet, so remove any copies of this node on open/closed lists
          open.remove(node_successor)
          closed.remove(node_successor)
          # set the parent node of node_successor to node_current
          node_successor.parent=node_current
          # set h to be the estimated distance to node_goal using the heuristic
          node_successor.calc_h(node_goal)
          # so now we know this is the best copy of the node so far, so put it onto the open list
          open.push(node_successor)
        }
        #now we've gone through all the successors, so the current node can be closed
        closed.push(node_current)
      end
    end
    
    def show_path(anode)
      #shows the path back from node 'anode' by following the parent pointer
      curr = anode
      pathmap = generate_costmap
      while curr.parent do
        pathmap[curr.y][curr.x] = '*'
        curr = curr.parent
      end
      pathmap[curr.y][curr.x] = '*'
      pathstr=""
      pathmap.each_index do |row|
        pathmap[row].each_index do |col|
          pathstr<<"|#{pathmap[row][col]}"
        end
        pathstr<<"|\n"
      end
      puts(pathstr)
    end
    
    def upper
      return @properties[:upper]
    end
    
    def lower
      return @properties[:lower]
    end
    
    def left
      return @properties[:left]
    end
    
    def right
      return @properties[:right]
    end
    
  end
end
