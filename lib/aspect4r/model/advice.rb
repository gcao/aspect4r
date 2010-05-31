module Aspect4r
  module Model
    class Advice
      BEFORE = 1
      AFTER  = 2
      AROUND = 3
    
      attr_accessor :type, :with_method, :group, :options
    
      def initialize type, with_method, group, options = {}
        @type        = type
        @with_method = with_method
        @group       = group
        @options     = options
      end
    
      def name
        options[:name] || with_method
      end
    
      %w(before after around).each do |aspect|
        class_eval <<-CODE
          def #{aspect}? 
            type == #{aspect.upcase}
          end
        CODE
      end
    end
  end
end