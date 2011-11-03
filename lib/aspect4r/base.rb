require 'aspect4r/errors'
require 'aspect4r/model/advice'
require 'aspect4r/model/aspect_data'
require 'aspect4r/model/advice_metadata'
require 'aspect4r/model/method_matcher'
require 'aspect4r/return_this'

require 'aspect4r/helper'

module Aspect4r
  module Base
    def self.included(base)
      base.extend(ClassMethods)

      eigen_class = class << base; self; end
      eigen_class.extend(ClassMethods)
    end

    module ClassMethods
      def method_added method
        super method

        return if Aspect4r::Helper.creating_method?

        method = method.to_s
        return if method[0..2] == "a4r"

        # save unbound method and create new method
        advices = a4r_data.advices_for_method(method)
        unless advices.empty?
          a4r_data.wrapped_methods[method] = instance_method(method)
          Aspect4r::Helper.create_method self, method
        end
      end

      def singleton_method_added method
        super method

        return if Aspect4r::Helper.creating_method?

        method = method.to_s
        return if method[0..2] == "a4r"

        eigen_class = class << self; self; end

        # save unbound method and create new method
        advices = eigen_class.a4r_data.advices_for_method(method)
        unless advices.empty?
          eigen_class.a4r_data.wrapped_methods[method] = eigen_class.instance_method(method)
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
          method = method.to_s
          advices = a4r_data.advices_for_method(method)
          next if advices.empty?

          send :alias_method, :"#{method}_with_advices", method
          Aspect4r::Helper.define_method self, method, a4r_data.wrapped_methods[method]
        end

        yield
      ensure
        methods.each do |method|
          method_with_advices = "#{method}_with_advices"

          next unless instance_methods.include?(RUBY_VERSION =~ /^1\.8/ ? method_with_advices : method_with_advices.to_sym)

          send :alias_method, method, method_with_advices
          self.send :remove_method, method_with_advices
        end
      end
    end
  end
end
