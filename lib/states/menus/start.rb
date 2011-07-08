
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
      @leaves = EH::Particles.new(:title_leaves, 512, 0)
      @song = EH::Song.new("Greendjohn - Rebirth")
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
  
end
