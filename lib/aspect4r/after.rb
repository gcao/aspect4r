require 'aspect4r/base'

module Aspect4r
  module After
    def self.included(base)
      base.send(:include, Base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def after_method *methods, &block
        methods.flatten!
        
        options = {}
        options.merge!(methods.pop) if methods.last.is_a? Hash

        if block_given?
          after_method = Aspect4r::Helper.find_available_method_name self, "a4r_after_"
          define_method after_method, &block
        else
          after_method = methods.pop
        end

        methods.each do |method|
          method = method.to_sym
          
          Aspect4r::Helper.backup_original_method self, method
          
          aspect = self.a4r_definitions[method] ||= AspectForMethod.new(method)
          aspect.add Aspect4r::Definition.after(after_method, options)
          
          Aspect4r::Helper.create_method_placeholder self, method
        end
      end
    end
  end
end