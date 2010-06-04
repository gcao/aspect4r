module Aspect4r
  module Model
    class AdvicesForMethod
      attr_reader :method
      attr_accessor :wrapped_method
    
      def initialize method
        @method = method
      end
    
      def advices
        @advices ||= []
      end
    
      def add new_advice
        advices << new_advice unless include?(new_advice)
      end
    
      def empty?
        @advices.nil? or @advices.empty?
      end
    
      def include? new_advice
        advices.detect { |advice| advice.name == new_advice.name }
      end
    
      def merge! another
        unless another.nil? or another.empty?
          another.advices.each do |advice|
            advices.push advice unless include?(advice)
          end
        end

        self
      end
    
      def clone
        o = self.class.new(method)
        o.advices.push *advices unless empty?

        o
      end
    end
  end
end