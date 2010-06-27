module Aspect4r
  module Model
    class Advice
      BEFORE = 1
      AFTER  = 2
      AROUND = 3

      # raw_options, logic_in_block and block_arity are for recording purpose.
      attr_reader :group
      attr_writer :logic_in_block
      attr_accessor :type, :with_method, :options, :raw_options, :block_arity
    
      def initialize type, with_method, group, options = {}
        @type        = type
        @with_method = with_method
        @group       = group
        @options     = options
      end
    
      def name
        options[:name] || with_method
      end
      
      def logic_in_block?
        @logic_in_block
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
      
      def advice_type_name
        if before?
          "Before"
        elsif before_filter?
          "Before Filter"
        elsif after?
          "After"
        elsif around?
          "Around"
        else
          "Invalid"
        end
      end
    end
  end
end