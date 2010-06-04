require 'aspect4r/before'
require 'aspect4r/after'
require 'aspect4r/around'

module Aspect4r
  def self.included(base)
    base.send(:include, Base::InstanceMethods)
    base.extend Base::ClassMethods, Before::ClassMethods, After::ClassMethods, Around::ClassMethods
  end
end