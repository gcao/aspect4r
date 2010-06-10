require 'set'

module Aspect4r
  module Model
    class AspectData < Hash
      def initialize *args
        super
      end
      
      def methods_with_advices
        @methods_with_advices ||= Set.new
      end
    end
  end
end