require 'aspect4r/base'

module Aspect4r
  module Before
    def self.included(base)
      base.send(:include, Base)
      base.extend(ClassMethods)
      
      eigen_class = class << base; self; end
      eigen_class.extend(ClassMethods)
    end

    module ClassMethods
      def before *methods, &block
        Aspect4r::Helper.process_advice Aspect4r::Model::AdviceMetadata::BEFORE, self, methods, &block
      end
    
      def before_filter *methods, &block
        Aspect4r::Helper.process_advice Aspect4r::Model::AdviceMetadata::BEFORE_FILTER, self, methods, &block
      end
    end
    
    module Classic
      def self.included(base)
        base.send(:include, Base)
        base.extend(ClassMethods)
      
        eigen_class = class << base; self; end
        eigen_class.extend(ClassMethods)
      end
    
      module ClassMethods
        def a4r_before *methods, &block
          Aspect4r::Helper.process_advice Aspect4r::Model::AdviceMetadata::BEFORE, self, methods, &block
        end
    
        def a4r_before_filter *methods, &block
          Aspect4r::Helper.process_advice Aspect4r::Model::AdviceMetadata::BEFORE_FILTER, self, methods, &block
        end
      end
    end
  end
end