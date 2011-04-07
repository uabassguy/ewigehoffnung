
require "game/map/map_particle.rb"

module EH::Game::NPC
  include EH::Game
  
  def self.make_pos(str, npc)
    if str.include?("@")
      str.gsub!("@x", "#{npc.x}")
      str.gsub!("@y", "#{npc.y}")
    end
    return str.to_pos
  end
  
  def self.make_msg_str(str)
    if str.include?("dialogue:")
      return EH::Trans.dialogue(str.gsub("dialogue:", "").to_sym)
    else
      return str
    end
  end
  
  def self.particles(ary, npc)
    ary.shift
    name = "particles-#{rand(100)}-#{ary[1]}"
    pos = make_pos(ary[0], npc)
    npc.properties.store("#{name}-x", pos[0])
    npc.properties.store("#{name}-y", pos[1])
    npc.properties.store("#{name}-effect", ary[1])
    if ary.include?("follow")
      prc = proc { |np|
        np.behaviour.update.push(
          Task.new(proc { |n|
              n.properties["#{name}-emitter"].x = n.x+16
              n.properties["#{name}-emitter"].y = n.y+16
            }, false, false)
        )
      }
    else
      prc = proc {}
    end
    task = Task.new(
      proc { |np, other|
        EH.window.state.map.misc.push(MapParticle.new(npc.properties["#{name}-x"], npc.properties["#{name}-y"], npc.properties["#{name}-effect"]))
        np.properties.store("#{name}-emitter", EH.window.state.map.misc.last)
        prc.call(np)
      },
      false, true)
    return task
  end
  
  def self.path_to(ary, npc)
    ary.shift
    ret = ary.include?("retry")
    remove = ary.include?("remove")
    task = MotionTask.new(
      proc { |np, other|
        np.find_path_to(ary[0].to_pos[0], ary[0].to_pos[1])
      },
      true, remove)
    return task
  end
  
  def self.msg(ary, npc)
    ary.shift
    msg = self.make_msg_str(ary.first)
    wait = ary.include?("wait")
    remove = ary.include?("remove")
    task = Task.new(proc { |np, other| EH.window.state.map.message(msg) }, wait, remove)
    return task
  end
  
end
