require 'aspect4r/helper'
require 'aspect4r/return_this'

module Aspect4r
  module Before
    def self.included(base)
       base.extend(ClassMethods)
    end

    module ClassMethods
      def before_method *methods, &block
        options = {:skip_if_false => false}
        options.merge!(methods.pop) if methods.last.is_a? Hash
      
        before_method = methods.pop unless block_given?

        methods.each do |method|
          new_method = Aspect4r::Helper.find_available_method_name self, "#{method}_"
          alias_method new_method, method
        
          if block_given?
            new_before_method = Aspect4r::Helper.find_available_method_name self, "#{method}_before_"
            define_method new_before_method, &block
          else
            new_before_method = before_method
          end
        
          define_method method do |*args|
            result = send new_before_method, *args
          
            if result.is_a? ReturnThis
              result.value
            elsif result or not options[:skip_if_false]
              send new_method, *args
            else
              result
            end
          end
        end
      end
    
      def before_method_check *methods, &block
        options = methods.last.is_a?(Hash) ? methods.pop : {}
        options.merge! :skip_if_false => true
        before_method *(methods + [options]), &block
      end
    end
  end
end