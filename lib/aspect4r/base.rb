require 'aspect4r/errors'
require 'aspect4r/model/advice'
require 'aspect4r/model/advices_for_method'
require 'aspect4r/model/aspect_data'
require 'aspect4r/model/advice_metadata'
require 'aspect4r/return_this'

require 'aspect4r/helper'

require 'aspect4r/extensions/class_extension'
require 'aspect4r/extensions/module_extension'

module Aspect4r
  module Base
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.extend(ClassMethods)
    end

    module InstanceMethods
      def a4r_invoke proxy, *args
        proxy.bind(self).call *args
      end
    end

    module ClassMethods
      def a4r_data
        @a4r_data ||= Aspect4r::Model::AspectData.new(self)
      end
      
      def a4r_group
        a4r_data.change_group
        
        if block_given?
          yield
          a4r_data.change_group
        end
      end
    end
  end
end