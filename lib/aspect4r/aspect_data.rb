module Aspect4r
  class AspectData < Hash
    def initialize *args
      super
    end
    
    def advices
      @advices ||= {}
    end
  end
end