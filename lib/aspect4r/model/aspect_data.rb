require 'set'

module Aspect4r
  module Model
    class AspectData < Array
      def initialize klass_or_module
        @group = klass_or_module.hash
      end

      def wrapped_methods
        @wrapped_methods ||= {}
      end

      def group_index
        @group_index ||= 0
      end

      def group
        "#{@group}:#{group_index}"
      end

      def change_group
        @group_index = group_index + 1
      end

      def advices_for_method method, is_existing_method = false
        method = method.to_s
        if is_existing_method
          select {|advice| !advice.next_method_only? && advice.match?(method) }
        else
          select {|advice| advice.match?(method) }
        end
      end
    end
  end
end
