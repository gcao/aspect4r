require 'aspect4r/errors'
require 'aspect4r/model/advice'
require 'aspect4r/model/advices_for_method'
require 'aspect4r/model/aspect_data'
require 'aspect4r/model/advice_metadata'
require 'aspect4r/return_this'

require 'aspect4r/helper'
require 'aspect4r/debugger'

require 'aspect4r/extensions/module_extension'

module Aspect4r
  module Base
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.extend(ClassMethods)
      base.instance_variable_set('@a4r_data', Aspect4r::Model::AspectData.new(base))
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
      
      def a4r_group &block
        a4r_data.change_group
        
        if block_given?
          instance_eval &block
          a4r_data.change_group
        end
      end

      def a4r_disable_advices_temporarily *methods
        methods.each do |method|
          advices = a4r_data[method.to_sym]
          next if advices.nil? or advices.empty?
          
          Aspect4r::Helper.define_method self, method, advices.wrapped_method
        end
        
        yield
      ensure
        methods.each do |method|
          advices = a4r_data[method.to_sym]
          
          next if advices.nil? or advices.empty?
          
          Aspect4r::Helper.create_method self, method
        end
      end
    end
  end
end