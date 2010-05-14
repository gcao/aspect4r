require 'aspect4r/class_ext'
require 'aspect4r/module_ext'
require 'aspect4r/return_this'
require 'aspect4r/definition'
require 'aspect4r/aspect_for_method'
require 'aspect4r/helper'

module Aspect4r
  module Base
    def self.included(base)
       base.extend(ClassMethods)
    end

    module ClassMethods
      def a4r_debug_mode debug_mode = true
        @a4r_debug_mode = debug_mode
      end
      
      def a4r_debug_mode?
        @a4r_debug_mode
      end
      
      def a4r_debug method, message
        puts "A4R - [#{method}] #{message}" if @a4r_debug_mode
      end
      
      def a4r_definitions
        @a4r_definitions ||= {}
      end
    end
  end
end