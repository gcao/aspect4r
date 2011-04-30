module Aspect4r
  module Model
    class MethodMatcher
      def initialize *match_data
        @match_data = match_data
      end
      
      def match? method
        @match_data.detect do |item|
          (item.is_a? String and item == method) or
          (item.is_a? Symbol and item.to_s == method) or
          (item.is_a? Regexp and item =~ method)
        end
      end
    end
  end
end