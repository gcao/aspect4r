require 'aspect4r/class_ext'
require 'aspect4r/return_this'
require 'aspect4r/definition'
require 'aspect4r/aspect_for_method'
require 'aspect4r/helper'
require 'aspect4r/module_ext'

module Aspect4r
  module Base
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def a4r_definitions
        @a4r_definitions ||= {}
      end
    end
  end
end