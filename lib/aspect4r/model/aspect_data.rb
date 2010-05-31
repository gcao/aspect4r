module Aspect4r
  module Model
    class AspectData < Hash
      def initialize *args
        super
      end
    
      def advices
        @advices ||= {}
      end
    end
  end
end