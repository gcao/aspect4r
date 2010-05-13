require 'aspect4r/base'

module Aspect4r
  module Before    
    def self.included(base)
      base.send(:include, Base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def before_method *methods, &block
        options = {:skip_if_false => false}
        options.merge!(methods.pop) if methods.last.is_a? Hash
      
        if block_given?
          before_method = Aspect4r::Helper.find_available_method_name self, "a4r_before_"
          define_method before_method, &block
        else
          before_method = methods.pop
        end

        methods.each do |method|
          method = method.to_sym
          
          a4r_rename_original_method method
          
          self.a4r_definitions[method] ||= []
          self.a4r_definitions[method] << Aspect4r::Definition.before(method, before_method, options)
          
          a4r_create_method method, self.a4r_definitions[method]
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