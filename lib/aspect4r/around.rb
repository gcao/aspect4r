require 'aspect4r/base'

module Aspect4r
  module Around
    def self.included(base)
      base.send(:include, Base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def around_method *methods, &block
        if block_given?
          around_method = Aspect4r::Helper.find_available_method_name self, "a4r_around_"
          define_method around_method, &block
        else
          around_method = methods.pop
        end

        methods.each do |method|
          method = method.to_sym
          
          Aspect4r::Helper.backup_original_method self, method
          
          self.a4r_definitions[method] ||= []
          self.a4r_definitions[method] << Aspect4r::Definition.around(method, around_method, options)
          
          Aspect4r::Helper.create_method self, method, self.a4r_definitions[method]
        end
      end
    end
  end
end