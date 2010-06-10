module Aspect4r
  module Model
    class AdvicesForMethod < Array
      attr_reader :method
      attr_accessor :wrapped_method
    
      def initialize method
        @method = method
      end
    
      def add new_advice
        self << new_advice unless include?(new_advice)
      end

      def include? new_advice
        detect { |advice| advice.name == new_advice.name }
      end
      
      def [] index
        return super unless index.is_a? String or index.is_a? Symbol
        
        detect {|advice| advice.name.to_sym == index.to_sym }
      end
    end
  end
end