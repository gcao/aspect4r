require 'aspect4r/before'
require 'aspect4r/after'
require 'aspect4r/around'
require 'aspect4r/classic'

module Aspect4r
  def self.included(base)
    base.send(:include, Before, After, Around)
  end
end