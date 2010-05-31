require 'aspect4r/errors'
require 'aspect4r/advice'
require 'aspect4r/advices_for_method'
require 'aspect4r/aspect_data'
require 'aspect4r/advice_metadata'
require 'aspect4r/return_this'

require 'aspect4r/helper'

require 'aspect4r/class_extension'
require 'aspect4r/module_extension'

module Aspect4r
  module Base
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def a4r_data
        @a4r_data ||= AspectData.new
      end
    end
  end
end