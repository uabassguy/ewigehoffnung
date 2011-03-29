
module EH::GUI
  class Slider < Element
    attr_accessor :value
    def initialize(x, y, w, h)
      super
      @value = 0
    end
  end
end
