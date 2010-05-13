require 'aspect4r/base'

module Aspect4r
  module After
    def self.included(base)
      base.send(:include, Base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def after_method *methods, &block
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
          
          a4r_rename_original_method method
          
          self.a4r_definitions[method] ||= []
          self.a4r_definitions[method] << Aspect4r::Definition.after(method, after_method, options)
          
          a4r_create_method method, self.a4r_definitions[method]
        end
      end
    end
  end
end