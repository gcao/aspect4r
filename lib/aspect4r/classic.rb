require 'aspect4r/before'
require 'aspect4r/after'
require 'aspect4r/around'

module Aspect4r
  module Classic
    def self.included(base)
      base.extend Base::ClassMethods, Before::Classic::ClassMethods, After::Classic::ClassMethods, Around::Classic::ClassMethods
    end
  end
end