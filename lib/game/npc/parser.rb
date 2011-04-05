
module EH::Game::NPC
  
  def self.particles(ary, npc)
    ary.shift
    task = Task.new(proc { |npc, other| puts("particle proc @ #{npc}") }, false, true)
    return task
  end
  
  def self.path_to(ary, npc)
    ary.shift
    ret = ary.include?("retry")
    remove = ary.include?("remove")
    task = MotionTask.new(
      proc { |npc, other|
        npc.find_path_to(ary[0].to_pos[0], ary[0].to_pos[1])
      },
      true, remove)
    return task
  end
  
  def self.msg(ary, npc)
    ary.shift
    wait = ary.include?("wait")
    remove = ary.include?("remove")
    task = Task.new(proc { |npc, other| puts("msg proc #{npc} <-- #{other}") }, wait, remove)
    return task
  end
  
end
