require 'aspect4r/base'
require 'aspect4r/helper'

module Aspect4r
  module After
    include Base
    
    def self.included(base)
       base.extend(ClassMethods)
    end

    module ClassMethods
      def after_method *methods, &block
        after_method = methods.pop unless block_given?

        methods.each do |method|
          new_method = Aspect4r::Helper.find_available_method_name self, "#{method}_"
          alias_method new_method, method
        
          if block_given?
            new_after_method = Aspect4r::Helper.find_available_method_name self, "#{method}_after_"
            define_method new_after_method, &block
          else
            new_after_method = after_method
          end
        
          define_method method do |*args|
            result = send new_method, *args
          
            send new_after_method, *([result] + args)
          end
        end
      end
    end
  end
end