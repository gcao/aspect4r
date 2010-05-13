require 'aspect4r/class_ext'
require 'aspect4r/return_this'
require 'aspect4r/definition'
require 'aspect4r/helper'

module Aspect4r
  module Base
    def self.included(base)
       base.extend(ClassMethods)
    end

    module ClassMethods
      def a4r_debug_mode debug_mode = true
        @a4r_debug_mode = debug_mode
      end
      
      def a4r_debug_mode?
        @a4r_debug_mode
      end
      
      def a4r_debug method, message
        puts "A4R - [#{method}] #{message}" if @a4r_debug_mode
      end
      
      def a4r_definitions
        @a4r_definitions ||= {}
      end
      
      # method      - target method
      # definitions - an array of Aspect4r::Definition
      def a4r_create_method method, definitions
        define_method method do |*args|
          self.class.a4r_debug method, "Entering #{method}(#{args.inspect[1..-2]})" if self.class.a4r_debug_mode?
          self.class.a4r_debug method, "Aspects: #{definitions.length}" if self.class.a4r_debug_mode?
          
          before_defs = definitions.select {|definition| definition.before? }
          
          self.class.a4r_debug method, "'before' aspects: #{before_defs.length}" if self.class.a4r_debug_mode?
          
          result = nil
          
          before_defs.each do |definition|
            self.class.a4r_debug method, "Aspect: #{definition.inspect}" if self.class.a4r_debug_mode?
            
            result = send(definition.with_method, *args)
            
            self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?
            
            break if result.is_a? ReturnThis
            
            if definition.options[:skip_if_false] and not result
              self.class.a4r_debug method, "Wrap up result with ReturnThis" if self.class.a4r_debug_mode?
  
              result = ReturnThis.new(result)
              break
            end
          end
          
          if result.is_a? ReturnThis
            self.class.a4r_debug method, "Leaving #{method} with result: #{result.value.inspect}" if self.class.a4r_debug_mode?
            return result.value
          end
          
          self.class.a4r_debug method, "Invoking original method" if self.class.a4r_debug_mode?
            
          result = send(:"#{method}_without_a4r", *args)
          
          self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?

          after_defs = definitions.select {|definition| definition.after? }
          
          self.class.a4r_debug method, "'after' aspects: #{after_defs.length}" if self.class.a4r_debug_mode?
          
          after_defs.each do |definition|
            self.class.a4r_debug method, "Aspect: #{definition.inspect}" if self.class.a4r_debug_mode?
            
            result = send(definition.with_method, *([result] + args))
            
            self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?
          end
          
          self.class.a4r_debug method, "Leaving #{method} with result: #{result.inspect}" if self.class.a4r_debug_mode?
          
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