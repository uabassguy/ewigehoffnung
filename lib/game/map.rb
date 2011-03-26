
module EH::Game
  require "ext/astar/node.rb"
  require "ext/astar/priority_queue.rb"
  require "game/tile.rb"
  class Map
    # TODO load that stuff from files
    # TODO xml parser for tiled maps
    MAP_Z = 0
    UNPASSABLES = [10]
    TILES = [10, 10, 11, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17]
    HEIGHT = 15
    def initialize(filename, window)
      @tiles = Array.new(15) { [] }
      file = File.new("maps/#{filename}.map")
      parse(file, window)
      file.close
      @costmap = nil
    end
    # TODO move to parse.rb
    def parse(file, window)
      @tiles = Array.new(HEIGHT) { [] }
      i = 0
      file.each_line { |line|
        parse_line(line, i, window)
        i += 1
      }
    end
    def parse_line(line, i, window)
      x = 0
      line.each_line(",") { |c|
        if c.include?("<") or c.include?(">")
          next
        end
        c.gsub!(",", "")
        if c == "0" || !c || c == "\n"
          next
        end
        if UNPASSABLES.include?(c.to_i)
          passable = false
        else
          passable = true
        end
        @tiles[i].push(Tile.new(window, passable, c, x*32, i*32, MAP_Z))
        x += 1
      }
    end
    
    def draw
      @tiles.each { |ary|
        ary.each { |tile|
          tile.draw
        }
      }
    end
    
    def passable?(x, y)
      # FIXME doesnt work right on moving characters
      # FIXME doesnt work on left edge
      p = @tiles[y/32][x/32].passable?
      if p
        obj = EH.window.state.find_object(x, y)
        if !obj
          return true
        end
        p = obj.through
      end
      return p
    end
    
    def generate_costmap(maxx=@tiles.compact.size)
      map = []
      x = 0
      @tiles.each { |ary|
        cary = []
        y = 0
        ary.each { |tile|
          if tile.passable?
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
        if x > maxx
          break
        end
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
      costmap = generate_costmap(node_goal.x)
      while !open.empty? do
        iterations += 1 #keep track of how many times this itersates
        node_current = open.find_best
        if node_current == node_goal
          puts("Iterations: #{iterations}")
          show_path(node_current)
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
      pathmap = generate_costmap(@tiles.compact.size).clone
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
  end
end
