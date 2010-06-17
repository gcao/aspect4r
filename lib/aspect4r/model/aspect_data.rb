require 'set'

module Aspect4r
  module Model
    class AspectData < Hash
      def initialize klass_or_module
        @klass_or_module = klass_or_module
      end
      
      def group_index
        @group_index ||= 0
      end
            
      def group
        "#{@klass_or_module.hash}:#{group_index}"
      end
      
      def change_group
        @group_index = group_index + 1
      end
    end
  end
end