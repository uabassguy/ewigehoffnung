
module EH
  class Config
    attr_reader :hash
    def initialize
      @hash = {
        :opengl => true,
        :language => "de",
        :volume => 0.5, # 0 = normal, 1 = twice as loud
        :contrast => 1.0, # 1.0 = off
        :log => true, # whether to log to file or print everything on stdout
        :text_speed => 5, # higher = slower
      }
    end
    def load(file=EH::DEFAULT_CONFIG)
      if !File.exists?(EH::HOME_PATH + file)
        File.new(EH::HOME_PATH + file, "w")
      else
        if File.size(EH::HOME_PATH + file) > 0
          begin
            @hash = Marshal.load(File.open(EH::HOME_PATH + file, "r"))
            validate
          rescue TypeError
            puts("WARNING: Corrupted config file (#{file}), reverting to default")
          end
        end
      end
    end
    def save(file=EH::DEFAULT_CONFIG)
      validate
      Marshal.dump(@hash, File.open(EH::HOME_PATH + file, "w"))
    end
    def validate
      if !["en", "de"].include?(@hash[:language])
        @hash[:language] = "de"
      end
      vol = @hash[:volume]
      if vol < 0
        @hash[:volume] = 0.0
      elsif vol > 1
        @hash[:volume] = 1.0
      end
      speed = @hash[:text_speed]
      if speed < 1
        @hash[:text_speed] = 1
      elsif speed > 10
        @hash[:text_speed] = 10
      end
    end
  end
end
