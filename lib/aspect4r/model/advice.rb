module Aspect4r
  module Model
    class Advice
      BEFORE = 1
      AFTER  = 2
      AROUND = 3
    
      attr_accessor :type, :with_method, :options
    
      def initialize type, with_method, options = {}
        @type        = type
        @with_method = with_method
        @options     = options
      end
    
      def name
        options[:name] || with_method
      end
      
      def before?
        type == BEFORE and not options[:skip_if_false]
      end
      
      def before_filter?
        type == BEFORE and options[:skip_if_false]
      end
      
      def after?
        type == AFTER
      end
      
      def around?
        type == AROUND
      end
      
      def invoke obj, *args
        obj.send with_method, *args
      end
    end
  end
end