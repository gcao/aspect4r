require 'aspect4r/errors'
require 'aspect4r/model/advice'
require 'aspect4r/model/advices_for_method'
require 'aspect4r/model/aspect_data'
require 'aspect4r/model/advice_metadata'
require 'aspect4r/return_this'

require 'aspect4r/helper'

module Aspect4r
  module Base
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.extend(ClassMethods)

      eigen_class = class << base; self; end
      eigen_class.send(:include, InstanceMethods)
      eigen_class.extend(ClassMethods)
    end

    module InstanceMethods
      def a4r_invoke proxy, *args
        proxy.bind(self).call *args
      end
    end

    module ClassMethods      
      def method_added method
        super method

        return if method.to_s[0..2] == "a4r"

        # save unbound method and create new method
        if method_advices = a4r_data[method] and not Aspect4r::Helper.creating_method?
          method_advices.wrapped_method = instance_method(method)
          Aspect4r::Helper.create_method self, method
        end
      end
  
      def singleton_method_added method
        super method
    
        return if method.to_s[0..2] == "a4r"

        eigen_class = class << self; self; end

        # save unbound method and create new method
        if method_advices = eigen_class.a4r_data[method] and not Aspect4r::Helper.creating_method?
          method_advices.wrapped_method = eigen_class.instance_method(method)
          Aspect4r::Helper.create_method eigen_class, method
        end
      end

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
          
          send :alias_method, :"#{method}_with_advices", method
          Aspect4r::Helper.define_method self, method, advices.wrapped_method
        end
        
        yield
      ensure
        methods.each do |method|
          advices = a4r_data[method.to_sym]
          
          next if advices.nil? or advices.empty?
          
          method_with_advices = :"#{method}_with_advices"
          send :alias_method, method, method_with_advices
          self.send :remove_method, method_with_advices
        end
      end
    end
  end
end