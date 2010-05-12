require 'aspect4r/helper'

module Aspect4r
  module Around
    def self.included(base)
       base.extend(ClassMethods)
    end

    module ClassMethods
      def around_method *methods, &block
        around_method = methods.pop unless block_given?

        methods.each do |method|
          new_method = Aspect4r::Helper.find_available_method_name self, "#{method}_"
          alias_method new_method, method
        
          if block_given?
            new_around_method = Aspect4r::Helper.find_available_method_name self, "#{method}_around_"
            define_method new_around_method, &block
          else
            new_around_method = around_method
          end

          define_method method do |*args|
            send new_around_method, *([new_method] + args)
          end
        end
      end
    end
  end
end