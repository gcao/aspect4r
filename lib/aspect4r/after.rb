require 'aspect4r/base'

module Aspect4r
  module After
    def self.included(base)
      base.send(:include, Base::InstanceMethods)
      base.extend(Base::ClassMethods, ClassMethods)
    end

    module ClassMethods
      def after *methods, &block
        Aspect4r::Helper.process_advice Aspect4r::Model::AdviceMetadata::AFTER, self, methods, &block
      end
    end
    
    module Classic
      def self.included(base)
        base.send(:include, Base::InstanceMethods)
        base.extend(Base::ClassMethods, ClassMethods)
      end

      module ClassMethods
        def a4r_after *methods, &block
          Aspect4r::Helper.process_advice Aspect4r::Model::AdviceMetadata::AFTER, self, methods, &block
        end
      end
    end
  end
end