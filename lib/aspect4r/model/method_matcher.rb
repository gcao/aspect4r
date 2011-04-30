module Aspect4r
  module Model
    # Performance improvement ideas: 
    #  convert symbols to string
    #  if there is only one item in match_data, generate simplified match? method on the fly
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