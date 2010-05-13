require 'aspect4r/class_ext'

module Aspect4r
  module Base
    def self.included(base)
       base.extend(ClassMethods)
    end

    module ClassMethods
      def a4r_debug debug_mode = true
        @a4r_debug_mode = debug_mode
      end
      
      def a4r_definitions
        @a4r_definitions ||= {}
      end
      
      # method      - target method
      # definitions - an array of Aspect4r::Definition
      def a4r_create_method method, definitions
        define_method method do |*args|
          result = nil
          
          definitions.select {|definition| definition.before? }.each do |definition|
            result = send(definition.with_method, *args)
            
            break if result.is_a? ReturnThis
            
            if definition.options[:skip_if_false] and not result
              result = ReturnThis.new(result)
              break
            end
          end
          
          return result.value if result.is_a? ReturnThis
            
          result = send(:"#{method}_without_a4r", *args)
          
          definitions.select {|definition| definition.after? }.each do |definition|
            result = send(definition.with_method, *([result] + args))
          end
          
          result
        end
      end
      
      def a4r_rename_original_method method
        method             = method.to_s
        method_without_a4r = "#{method}_without_a4r"

        if instance_methods.include?(method) and not instance_methods.include?(method_without_a4r)
          alias_method method_without_a4r, method
        end
      end
    end
  end
end