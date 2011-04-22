require 'aspect4r/base'

module Aspect4r
  module Around
    def self.included(base)
      base.send(:include, Base)
      base.extend(ClassMethods)
      
      eigen_class = class << base; self; end
      eigen_class.send(:include, Base)
      eigen_class.extend(ClassMethods)
    end

    module ClassMethods
      def around *methods, &block
        Aspect4r::Helper.process_advice Aspect4r::Model::AdviceMetadata::AROUND, self, methods, &block
      end
    end
    
    module Classic
      def self.included(base)
        base.send(:include, Base)
        base.extend(ClassMethods)
      
        eigen_class = class << base; self; end
        eigen_class.send(:include, Base)
        eigen_class.extend(ClassMethods)
      end

      module ClassMethods
        def a4r_around *methods, &block
          Aspect4r::Helper.process_advice Aspect4r::Model::AdviceMetadata::AROUND, self, methods, &block
        end
      end
    end
  end
end