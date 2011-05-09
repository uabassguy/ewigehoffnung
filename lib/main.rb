
require "rubygems"
require "eh.rb"
require "game_window.rb"

# :main:EH

begin
  g = EH::GameWindow.new
  g.show
  EH.exit(0)
rescue Interrupt
  warn("Interrupted!")
  EH.exit(1)
rescue => ex
  puts("#{ex.class}: #{ex}\n#{ex.backtrace.join("\n").gsub("#{EH::LIBRARY_PATH}/", "")}")
  EH.exit(1)
end
