require 'aspect4r/base'

module Aspect4r
  module Around
    def self.included(base)
      base.send(:include, Base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def around *methods, &block
        Aspect4r::Helper.process_advice Metadata::AROUND, self, methods, &block
      end
    end
    
    module Classic
      def self.included(base)
        base.send(:include, ::Aspect4r::Base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def around_method *methods, &block
          Aspect4r::Helper.process_advice Metadata::AROUND, self, methods, &block
        end
      end
    end
  end
end